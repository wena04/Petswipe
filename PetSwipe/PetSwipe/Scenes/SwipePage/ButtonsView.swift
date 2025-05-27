//
//  ButtonsView.swift
//  PetSwipe
//
//  Created by Amelia Li on 5/27/25.
//

import UIKit

class ButtonsView: SwipeBaseView {
    
    lazy var likeButton: UIButton = {
        let b = ButtonStorage.buttonWithImage(
            image: UIImage(systemName: "heart.fill")!,
            cornerRadius: 0,
            target: self,
            selector: #selector(like),
            sizeToFit: false
        ).new
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()

    lazy var passButton: UIButton = {
        let b = ButtonStorage.buttonWithImage(
            image: UIImage(systemName: "heart.slash.fill")!,
            cornerRadius: 0,
            target: self,
            selector: #selector(pass),
            sizeToFit: false
        ).new
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()
    
    lazy var container: UIStackView = {
        let c = UIStackView(arrangedSubviews: [likeButton, passButton])
        c.translatesAutoresizingMaskIntoConstraints = false
        c.spacing = 30
        c.distribution = .fillEqually
        return c
    }()

    override func setUpViews() {
        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        [likeButton, passButton].forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 30),
                button.widthAnchor.constraint(equalToConstant: 30)
            ])
        }
    }
        
    @objc func like() {
        print("like print")
    }
    
    @objc func pass() {
        print("pass print")
    }
    
}
