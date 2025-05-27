//
//  SwipeBaseView.swift
//  PetSwipe
//
//  Created by Amelia Li on 5/27/25.
//

import Foundation
import UIKit

class SwipeBaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {}
}
