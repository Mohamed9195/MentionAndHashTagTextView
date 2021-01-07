//
//  AllFriendTableViewCell.swift
//  Hebat
//
//  Created by mohamed hashem on 06/01/2021.
//  Copyright © 2021 mohamed hashem. All rights reserved.
//

import UIKit

class AllFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var talentedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
