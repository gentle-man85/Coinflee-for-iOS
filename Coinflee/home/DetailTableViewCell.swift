//
//  DetailTableViewCell.swift
//  Coinflee
//
//  Created by kcg on 3/10/19.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import Charts

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol BuySellButtonDelegate {
    func BuyButtonTapped()
    func SellButtonTapped()
}

class DetailTableViewButtonCell: UITableViewCell {
    
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var sellBtn: UIButton!
    
    var delegate: BuySellButtonDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buyBtnTapped(_ sender: Any) {
        delegate?.BuyButtonTapped()
    }
    @IBAction func sellBtnTapped(_ sender: Any) {
        delegate?.SellButtonTapped()
    }
}


class DetailTableViewHeaderCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var middleFView: UIView!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var addBtn: UIButton!
    
    var chartDates: [Double] = []
    var delegate: AddButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        middleView.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        
        let cornerRadius_middlef = 5
        middleFView.layer.cornerRadius = CGFloat(cornerRadius_middlef)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chart!.centerViewToAnimated(xValue: entry.x, yValue: entry.y, axis: (chart.data?.getDataSetByIndex(highlight.dataSetIndex)?.axisDependency)!, duration: 1)
        
        let formatter = NumberFormatter()
        formatter.currencyCode = quoteCurrency
        formatter.numberStyle = .currency
        if Double(entry.y) > 1 {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 6
            formatter.maximumFractionDigits = 6
        }
        price.text = formatter.string(from: NSNumber(value: Double(entry.y)))
        let x = chartDates[Int(entry.x)]
        let _date = Date(timeIntervalSince1970: x)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy-ha"
        date.text = dateFormatter.string(from: _date)
        
    }
    
    @IBAction func AddBtnTapped(_ sender: Any) {
        delegate?.addButtonTapped()
    }
    
}
