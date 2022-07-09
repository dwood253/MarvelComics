//
//  ViewController.swift
//  MarvelComics
//
//  Created by Daniel on 7/6/22.
//

import UIKit
import Combine

fileprivate let CELL_ID = "comicCollectionCellId"
fileprivate let CELL_SPACING: CGFloat = 10.0
fileprivate let COMIC_DATA_LOAD_FAILURE = "A failure occurred trying to get the comics! ~ "
fileprivate let MISSING_KEYS_MESSAGE = "API Keys Not found! Check \"API Keys\" section of ReadMe"

class HomeVC: UIViewController {

    lazy var homeViewModel = HomeViewModel()
    lazy var comics: [Comic] = [] {
        didSet {
            reloadCollectionWithAnimation()
        }
    }
    lazy var subscriptions = Set<AnyCancellable>()
    
    var comicsCollection: UICollectionView!
    
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSubscriptions()
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: UI Setup
    fileprivate func setupUI() {
        setupComicCollection()
    }
    
    fileprivate func setupComicCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CELL_SPACING
        cellWidth = min(UIScreen.main.bounds.width/2 - CELL_SPACING, UIScreen.main.bounds.height/2 - CELL_SPACING)
        cellHeight = cellWidth * 1.5
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        comicsCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        comicsCollection.translatesAutoresizingMaskIntoConstraints = false
        comicsCollection.delegate = self
        comicsCollection.dataSource = self
        comicsCollection.register(comicCollectionCell.self, forCellWithReuseIdentifier: CELL_ID)
        //        comicCollection.contentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0)
        
        
        self.view.addSubview(comicsCollection)
        comicsCollection.fillSuperView(insets: UIEdgeInsets(top: 0, left: CELL_SPACING/2, bottom: 0, right: CELL_SPACING/2))
    }
    
    //MARK: - Combine Subscriptions
    fileprivate func setupSubscriptions() {
        homeViewModel.comics
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    var message = COMIC_DATA_LOAD_FAILURE
                    switch error {
                    case FetchError.missingAPIKeys:
                        message += MISSING_KEYS_MESSAGE
                    default:
                        message += error.localizedDescription
                        
                    }
                    DispatchQueue.main.async {
                        self.showToast(message: message)
                    }
                default:
                    return
                }
            } receiveValue: { [weak self] comics in
                guard let self = self else { return }
                self.comics = comics
            }
            .store(in: &subscriptions)
        
    }
    
    //MARK: - DATA
    fileprivate func getData() {
        homeViewModel.getComics()
    }
    
    //MARK: - Helpers
    fileprivate func reloadCollectionWithAnimation() {
        DispatchQueue.main.async {
            UIView.transition(with: self.comicsCollection, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.comicsCollection.reloadData()
            }, completion: nil)
        }
    }
}

//MARK: - UICollectionView delegate and data source
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! comicCollectionCell
        cell.setImage(image: comics[indexPath.row].thumbnail, title: comics[indexPath.row].title ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK: - Comic Collection View Cell
class comicCollectionCell: UICollectionViewCell {
    
    lazy var cellImage: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.layer.cornerRadius = 4
        imv.clipsToBounds = true
        return imv
    }()
    
    lazy var cellTitle: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        self.contentView.addSubview(cellImage)
        cellImage.fillSuperView()
        
        self.contentView.addSubview(cellTitle)
        NSLayoutConstraint.activate([
            cellTitle.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, constant: -10),
            cellTitle.centerXAnchor.constraint(equalTo: cellImage.centerXAnchor),
            cellTitle.centerYAnchor.constraint(equalTo: cellImage.centerYAnchor)
        ])
    }
    
    fileprivate func setImage(image: Image?, title: String) {
        guard let imagePath = image?.path, let imageExtension = image?.image_extension else { return }
        if imagePath.contains("image_not_available") {
            replaceImageWith(image: nil)
            self.cellImage.contentMode = .scaleAspectFill
            self.cellTitle.text = title
        } else {
            Task {
                do {
                    let image = try await NetworkManager.shared.fetchImage(for: imagePath, doctype: imageExtension)
                    replaceImageWith(image: image)
                    self.cellImage.contentMode = .scaleAspectFit
                    self.cellTitle.text = ""
                } catch let error {
                    print(error.localizedDescription)
                    replaceImageWith(image: nil)
                    //TODO: log this error
                }
            }
        }
    }

    fileprivate func replaceImageWith(image: UIImage?) {
        UIView.transition(with: self.cellImage, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.cellImage.image = image ?? UIImage(named: "placeholder")
        }, completion: nil)
    }
}

