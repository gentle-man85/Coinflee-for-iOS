//
//  coinTableViewCell.swift
//  Bitcoin
//
//  Created by Alex on 30/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import Charts

class coinTableViewCell: UITableViewCell {

    @IBOutlet weak var coinName: UILabel!
    
    @IBOutlet weak var coinChart: LineChartView!
    
    
    @IBOutlet weak var coinPrice: UILabel!
    @IBOutlet weak var smallCoinName: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var numberCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    

}
