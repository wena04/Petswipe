//
//  ButtonsView.swift
//  PetSwipe
//
//  Created by Amelia Li on 5/27/25.
//

import UIKit

class ButtonsView: SwipeBaseView {
    
    var onLike: (() -> Void)?
    var onPass: (() -> Void)?
    var onRefresh: (() -> Void)?
    
    lazy var likeButton: UIButton = {
        let b = ButtonStorage.buttonWithImage(
            image: UIImage(systemName: "heart.fill")!,
            cornerRadius: 0,
            target: self,
            selector: #selector(like),
            sizeToFit: false
        ).new
        b.imageView?.contentMode = .scaleAspectFit
        b.imageView?.tintColor = .systemPink
        b.imageView?.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
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
        b.imageView?.tintColor = .systemGray
        b.imageView?.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        return b
    }()
    
    lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var mainButtonsContainer: UIStackView = {
        let c = UIStackView(arrangedSubviews: [likeButton, passButton])
        c.translatesAutoresizingMaskIntoConstraints = false
        c.spacing = 60
        c.distribution = .equalSpacing
        return c
    }()
    
    lazy var container: UIStackView = {
        let c = UIStackView(arrangedSubviews: [mainButtonsContainer, refreshButton])
        c.translatesAutoresizingMaskIntoConstraints = false
        c.spacing = 10
        c.axis = .vertical
        c.alignment = .center
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
                button.widthAnchor.constraint(equalToConstant: 80),
                button.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        NSLayoutConstraint.activate([
            refreshButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc func like() {
        print("like")
        onLike?()
    }

    @objc func pass() {
        print("pass")
        onPass?()
    }
    
    @objc func refresh() {
        print("refresh")
        onRefresh?()
    }
}
