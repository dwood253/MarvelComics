//
//  Extension+UIView.swift
//  MarvelComics
//
//  Created by Daniel on 7/7/22.
//

import UIKit

extension UIView {
    func fillSuperView(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom)
        ])
    }
}
