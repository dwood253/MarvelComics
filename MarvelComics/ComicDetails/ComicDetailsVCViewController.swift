//
//  ComicDetailsVCViewController.swift
//  MarvelComics
//
//  Created by Daniel on 7/9/22.
//

import UIKit

fileprivate let BUTTON_DIMENSION: CGFloat = 30
fileprivate let BUTTON_PADDING: CGFloat = 10

class ComicDetailsVCViewController: UIViewController {
    
    lazy var containerView: UIView = {
        let v = UIView()
        return v
    }()

    lazy var backBackgroundImage: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    lazy var comicImage: UIImageView = {
       let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.layer.cornerRadius = 4
        imv.clipsToBounds = true
        return imv
    }()
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: BUTTON_DIMENSION).isActive = true
        btn.widthAnchor.constraint(equalToConstant: BUTTON_DIMENSION).isActive = true
        return btn
    }()
    
    //MARK: - Lifecycle
    init(image: UIImage?, comicFrame: CGRect, containerFrame: CGRect, comic: Comic) {
        super.init(nibName: nil, bundle: nil)
        comicImage.image = image
        comicImage.frame = comicFrame
        containerView.frame = containerFrame

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
    }
    
    //MARK: - Setup UI Elements
    func setupUI() {
        
        self.view.addSubviews([containerView])
        containerView.addSubviews([comicImage, closeButton])
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: BUTTON_PADDING),
            closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -BUTTON_PADDING)
        ])
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
    func getImageWithBlur(_ image: UIImage) -> UIImage? {
        guard let filter = CIFilter(name: "CIGaussianBlur"), let cropFilter = CIFilter(name: "CICrop"), let ogImage = CIImage(image: image) else { return nil }
       
        filter.setValue(ogImage, forKey: kCIInputImageKey)
        filter.setValue(5, forKey: kCIInputRadiusKey)
        
        cropFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: ogImage.extent), forKey: "inputRectangle")
        
        guard let cropOutput = cropFilter.outputImage, let contextOutput = context.createCGImage(cropOutput, from: cropOutput.extent) else { return nil }
        return UIImage(cgImage: contextOutput)
    }
}
