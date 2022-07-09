//
//  Extension+UIViewController.swift
//  MarvelComics
//
//  Created by Daniel on 7/8/22.
//

import Foundation
import UIKit
extension UIViewController {
 
    func showToast (message: String) {
        let toastContainer = UIView()
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.backgroundColor = .secondarySystemGroupedBackground
        toastContainer.layer.cornerRadius = 10
        
        
        let toast = UILabel()
        toast.text = message
        toast.numberOfLines = 0
        toast.lineBreakMode = .byWordWrapping
        toast.textAlignment = .center
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.textColor = .label
        DispatchQueue.main.async {
            toastContainer.addSubview(toast)
            self.view.addSubview(toastContainer)
            NSLayoutConstraint.activate([
                toastContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                toastContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                toastContainer.widthAnchor.constraint(equalTo: toast.widthAnchor, constant: 40),
                toastContainer.heightAnchor.constraint(equalTo: toast.heightAnchor, constant: 20),
                
                toast.centerXAnchor.constraint(equalTo: toastContainer.centerXAnchor),
                toast.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
                toast.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, constant: -40)
            ])
            UIView.animate(withDuration: 5, delay: 0, options: .transitionCrossDissolve, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in toastContainer.removeFromSuperview() })
        }
    }
}
