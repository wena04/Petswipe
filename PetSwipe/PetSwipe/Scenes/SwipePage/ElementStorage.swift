//
//  ElementStorage.swift
//  PetSwipe
//
//  Created by Amelia Li on 5/27/25.
//

import Foundation
import UIKit

enum ElementStorage {
    case standardLabel(text: String, textColor: UIColor, fontStyle: UIFont.TextStyle, textAlignment: NSTextAlignment?, sizeToFit: Bool, adjustToFit: Bool)
    var new: UILabel {
        switch self {
        case .standardLabel(let text,let textColor,let fontStyle, let textAlignment,let sizeToFit, let adjustToFit):
            return createStandardLabel(text: text, textColor: textColor, fontStyle: fontStyle, textAlignment: textAlignment, sizeToFit: sizeToFit, adjustToFit: adjustToFit)
        }
    }
    
    private func createStandardLabel(text: String, textColor: UIColor, fontStyle: UIFont.TextStyle, textAlignment: NSTextAlignment?, sizeToFit: Bool, adjustToFit: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = adjustToFit
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: fontStyle)
        label.textAlignment = textAlignment ?? .left
        label.textColor = textColor
        if sizeToFit {
            label.sizeToFit()
        }
      return label
   }
}
