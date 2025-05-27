//
//  ViewController.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit

class SwipePage: UIViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    lazy var petCard: PetCard = {
        let tc = PetCard()
       tc.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeCard(sender:))))
        return tc
    }()
    
    let buttonsContainer: ButtonsView = {
        let c = ButtonsView()
        return c
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setUpViews()
    }
    
    func setUpViews() {
        
        view.addSubview(petCard)
        view.addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            petCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            petCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            petCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            petCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70),
            
            buttonsContainer.topAnchor.constraint(equalTo: petCard.bottomAnchor, constant: 50),
            buttonsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsContainer.widthAnchor.constraint(equalTo: petCard.widthAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // pin
        ])
    }
    
    @objc func swipeCard(sender: UIPanGestureRecognizer) {
        sender.swipeView(petCard)
    }
}

