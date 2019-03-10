//
//  CurrencyTableViewCell.swift
//  Bitcoin
//
//  Created by Alex on 03/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var firstLabel: UILabel!
    
    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var lastLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //imageView?.isHidden = false
    }

}
