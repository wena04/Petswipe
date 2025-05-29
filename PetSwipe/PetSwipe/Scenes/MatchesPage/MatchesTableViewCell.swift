//
//  MatchesTableViewCell.swift
//  PetSwipe
//
//  Created by George Lee on 5/25/25.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

    @IBOutlet weak var matchImage: UIImageView!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    
    

}
