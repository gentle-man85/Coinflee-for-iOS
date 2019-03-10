//
//  SelectTableViewCell.swift
//  Bitcoin
//
//  Created by Team on 04/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit

class SelectTableViewCell: UITableViewCell {

    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
