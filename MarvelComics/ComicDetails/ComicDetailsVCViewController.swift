//
//  ComicDetailsVCViewController.swift
//  MarvelComics
//
//  Created by Daniel on 7/9/22.
//

import UIKit

fileprivate let BUTTON_DIMENSION: CGFloat = 30
fileprivate let BUTTON_PADDING: CGFloat = 10

fileprivate let READ_NOW_TEXT = "READ NOW"
fileprivate let MARK_AS_READ_ICON_IMAGE = "checkmark.circle.fill"
fileprivate let READ_NOW_TEXT_HEIGHT: CGFloat = 40
fileprivate let READ_NOW_TEXT_PADDING: CGFloat = 12

fileprivate let MARK_AS_READ_TEXT = "MARK AS READ"
fileprivate let ADD_TO_LIBRARY_ICON_IMAGE = "plus.circle.fill"
fileprivate let ADD_TO_LIBRARY_TEXT = "ADD TO LIBRARY"
fileprivate let READ_OFFLINE_ICON_IMAGE = "arrow.down.to.line.compact"
fileprivate let READ_OFFLINE_TEXT = "READ OFFLINE"
fileprivate let OPTION_BUTTON_ITEM_HEIGHT: CGFloat = 30
fileprivate let OPTION_BUTTON_ICON_DIMENSION: CGFloat = 15
fileprivate let OPTION_BUTTON_ITEM_PADDING: CGFloat = 12
fileprivate let OPTION_BUTTON_SEPERATOR_PADDING: CGFloat = 8
fileprivate let COMIC_OPTIONS_SIDE_PADDING: CGFloat = 5

protocol comicDetailsDelegate {
    func nextComicClicked()
    func previousComicClicked()
}

class ComicDetailsVCViewController: UIViewController {
    
    lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Color.background
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    lazy var backgroundImage: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.alpha = 0
        return imv
    }()
    lazy var comicImage: UIImageView = {
       let imv = UIImageView()
        imv.layer.cornerRadius = 4
        imv.clipsToBounds = true
        return imv
    }()
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .lightGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: BUTTON_DIMENSION).isActive = true
        btn.widthAnchor.constraint(equalToConstant: BUTTON_DIMENSION).isActive = true
        return btn
    }()
    lazy var imageOverlayTitle: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let comicInfo: Comic
    let isPlaceholderImage: Bool
    var scrollViewTopAnchor: NSLayoutConstraint!
    let comicDelegate: comicDetailsDelegate
    
    lazy var buttonContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        return v
    }()
    
    //MARK: - Lifecycle
    init(image: UIImage?, comicFrame: CGRect, comic: Comic, isPlaceholderImage: Bool, delegate: comicDetailsDelegate) {
        self.isPlaceholderImage = isPlaceholderImage
        self.comicInfo = comic
        comicDelegate = delegate
        super.init(nibName: nil, bundle: nil)
        comicImage.image = image
        comicImage.frame = comicFrame
        backgroundImage.image = getImageWithBlur(image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        executeComicAnimation()
        executeOtherFadeIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = containerView.frame.size
        scrollViewTopAnchor.constant = -scrollView.safeAreaInsets.top
    }
    
    //MARK: - Setup UI Elements
    func setupUI() {
        self.view.backgroundColor = Color.background?.withAlphaComponent(0)
        self.view.addSubviews([scrollView])
        scrollViewTopAnchor = scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([
            scrollViewTopAnchor,
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 900)
        ])
        setupButtonStack()
        handlePlaceholder()
        containerView.addSubviews([backgroundImage, closeButton, buttonContainer, comicImage])
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            backgroundImage.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: self.view.frame.size.height/2),
            backgroundImage.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: BUTTON_PADDING),
            backgroundImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonContainer.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: comicImage.frame.size.width + COMIC_OPTIONS_SIDE_PADDING*2),
            buttonContainer.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: -COMIC_OPTIONS_SIDE_PADDING),
            buttonContainer.centerYAnchor.constraint(equalTo: backgroundImage.centerYAnchor),
            
            closeButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: BUTTON_PADDING),
            closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -BUTTON_PADDING)
        ])
    }
    
    func setupButtonStack() {
        let readNowButton = getReadNowButton()
        let markAsReadButton = getComicOptionsButton(iconName: MARK_AS_READ_ICON_IMAGE, text: MARK_AS_READ_TEXT, selector: #selector(markAsRead))
        let addToLibraryButton = getComicOptionsButton(iconName: ADD_TO_LIBRARY_ICON_IMAGE, text: ADD_TO_LIBRARY_TEXT, selector: #selector(addToLibrary))
        let readOfflineButton = getComicOptionsButton(iconName: READ_OFFLINE_ICON_IMAGE, text: READ_OFFLINE_TEXT, selector: #selector(readOffline))
        
        buttonContainer.addSubviews([readNowButton, markAsReadButton, addToLibraryButton, readOfflineButton])
        NSLayoutConstraint.activate([
            readNowButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            readNowButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            readNowButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            markAsReadButton.topAnchor.constraint(equalTo: readNowButton.bottomAnchor, constant: OPTION_BUTTON_SEPERATOR_PADDING),
            markAsReadButton.leadingAnchor.constraint(equalTo: readNowButton.leadingAnchor),
            markAsReadButton.trailingAnchor.constraint(equalTo: readNowButton.trailingAnchor),
            addToLibraryButton.topAnchor.constraint(equalTo: markAsReadButton.bottomAnchor, constant: OPTION_BUTTON_SEPERATOR_PADDING),
            addToLibraryButton.leadingAnchor.constraint(equalTo: readNowButton.leadingAnchor),
            addToLibraryButton.trailingAnchor.constraint(equalTo: readNowButton.trailingAnchor),
            readOfflineButton.topAnchor.constraint(equalTo: addToLibraryButton.bottomAnchor, constant: OPTION_BUTTON_SEPERATOR_PADDING),
            readOfflineButton.leadingAnchor.constraint(equalTo: readNowButton.leadingAnchor),
            readOfflineButton.trailingAnchor.constraint(equalTo: readNowButton.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: readOfflineButton.bottomAnchor, constant: OPTION_BUTTON_SEPERATOR_PADDING)
        ])
    }
    
    func handlePlaceholder() {
        if isPlaceholderImage {
            imageOverlayTitle.text = comicInfo.title ?? ""
            //add comic image title overlay
            self.comicImage.addSubview(imageOverlayTitle)
            NSLayoutConstraint.activate([
                imageOverlayTitle.widthAnchor.constraint(lessThanOrEqualTo: comicImage.widthAnchor, constant: -10),
                imageOverlayTitle.centerXAnchor.constraint(equalTo: comicImage.centerXAnchor),
                imageOverlayTitle.centerYAnchor.constraint(equalTo: comicImage.centerYAnchor)
            ])
            comicImage.contentMode = .scaleAspectFill
            comicImage.layer.borderWidth = 2
            comicImage.layer.borderColor = UIColor.black.cgColor
        } else {
            comicImage.contentMode = .scaleAspectFit
        }
    }
    
    //MARK: - Animations
    
    fileprivate func executeComicAnimation() {
        let comicMoveAnimation = CABasicAnimation(keyPath: "position")
        comicMoveAnimation.fromValue = CGPoint(x: comicImage.frame.origin.x + comicImage.frame.size.width/2, y: comicImage.frame.origin.y + comicImage.frame.size.height/2)
        let centerY = backgroundImage.frame.height/2 + backgroundImage.frame.origin.y
        let centerX = comicImage.frame.width/2 + COMIC_OPTIONS_SIDE_PADDING
        let destination = CGPoint(x: centerX, y: centerY)
        comicMoveAnimation.toValue = destination
        comicMoveAnimation.duration = 0.5
        comicMoveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.comicImage.layer.add(comicMoveAnimation, forKey: "basic")
            self.comicImage.layer.position = destination
        })
    }
    
    fileprivate func executeOtherFadeIn() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.view.backgroundColor = Color.background
            self.backgroundImage.alpha = 1
            self.buttonContainer.alpha = 1
        })
    }
    
    //MARK: - Helpers
    
    @objc func closeTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
    
    var context = CIContext(options: nil)
    func getImageWithBlur(_ image: UIImage?) -> UIImage? {
        guard let image = image, let filter = CIFilter(name: "CIGaussianBlur"), let cropFilter = CIFilter(name: "CICrop"), let ogImage = CIImage(image: image) else { return nil }
       
        filter.setValue(ogImage, forKey: kCIInputImageKey)
        filter.setValue(5, forKey: kCIInputRadiusKey)
        
        cropFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: ogImage.extent), forKey: "inputRectangle")
        
        guard let cropOutput = cropFilter.outputImage, let contextOutput = context.createCGImage(cropOutput, from: cropOutput.extent) else { return nil }
        return UIImage(cgImage: contextOutput)
    }
    
    func getReadNowButton() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = Color.violet
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = READ_NOW_TEXT
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        textLabel.textColor = .lightGray
        container.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: READ_NOW_TEXT_PADDING),
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: READ_NOW_TEXT_HEIGHT),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -READ_NOW_TEXT_PADDING)
        ])
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(readNow)))
        return container
    }
    
    func getComicOptionsButton(iconName: String, text: String, selector: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = Color.background
        
        let iconImage = UIImageView(image: UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate))
        iconImage.tintColor = .lightGray
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.contentMode = .scaleAspectFit
        
        let spacerPipe = UIView()
        spacerPipe.translatesAutoresizingMaskIntoConstraints = false
        spacerPipe.backgroundColor = .lightGray
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.textColor = .lightGray
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        container.addSubviews([iconImage, spacerPipe, textLabel])
        
        NSLayoutConstraint.activate([
            iconImage.topAnchor.constraint(equalTo: container.topAnchor, constant: OPTION_BUTTON_ITEM_PADDING),
            iconImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: OPTION_BUTTON_ITEM_PADDING/2),
            iconImage.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -OPTION_BUTTON_ITEM_PADDING),
            iconImage.widthAnchor.constraint(equalToConstant: OPTION_BUTTON_ICON_DIMENSION),
            iconImage.heightAnchor.constraint(equalToConstant: OPTION_BUTTON_ICON_DIMENSION),
            
            spacerPipe.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: OPTION_BUTTON_ITEM_PADDING/2),
            spacerPipe.widthAnchor.constraint(equalToConstant: 1),
            spacerPipe.heightAnchor.constraint(equalToConstant: OPTION_BUTTON_ITEM_HEIGHT - OPTION_BUTTON_SEPERATOR_PADDING),
            spacerPipe.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: spacerPipe.trailingAnchor, constant: OPTION_BUTTON_ITEM_PADDING/2),
            textLabel.heightAnchor.constraint(equalToConstant: OPTION_BUTTON_ITEM_HEIGHT),
            textLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor)
        ])
        container.isUserInteractionEnabled = true
        let optionTappedGesture = UITapGestureRecognizer(target: self, action: selector)
        container.addGestureRecognizer(optionTappedGesture)
        return container
    }
    
    //MARK: - Comic Option Actions
    @objc func readNow() {
        print("readNow")
    }
    
    @objc func markAsRead() {
        print("markAsRead")
    }
    
    @objc func addToLibrary() {
        print("addToLibrary")
    }
    
    @objc func readOffline() {
        print("readOffline")
    }
    
}
