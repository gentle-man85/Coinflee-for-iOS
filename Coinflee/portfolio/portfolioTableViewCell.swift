//
//  portfolioTableViewCell.swift
//  Bitcoin
//
//  Created by Alex on 2/19/19.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import Charts


class portfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinPrice: UILabel!
    @IBOutlet weak var coinProfit: UILabel!
    @IBOutlet weak var coinRate: UILabel!
    @IBOutlet weak var coinTotalPrice: UILabel!
    @IBOutlet weak var coinAmount: UILabel!
      
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

protocol AddButtonDelegate {
    func addButtonTapped()
}

class portfolioTableViewHeaderCell: UITableViewCell, ChartViewDelegate  {
    
    @IBOutlet weak var TotalPortfolio: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var profit: UILabel!   
    
    
    @IBOutlet weak var chart: LineChartView!
    
    @IBOutlet weak var Name: UILabel!    
    @IBOutlet weak var Profit1: UILabel!
    @IBOutlet weak var Price1: UILabel!
    @IBOutlet weak var Total1: UILabel!
    
    @IBOutlet weak var middleFView: UIView!
    @IBOutlet weak var AddButton: UIButton!
    
    var language = LanguageFile()
    var chartDates: [Double] = []
    var profit_rate: [[Double]] = []
    
    var delegate: AddButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cornerRadius_middlef = 5
        middleFView.layer.cornerRadius = CGFloat(cornerRadius_middlef)
        
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = false
        chart.legend.enabled = false
        chart.drawGridBackgroundEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.highlightPerTapEnabled = true
        chart.backgroundColor = #colorLiteral(red: 0, green: 0.3558115605, blue: 0.5942655457, alpha: 1)
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if chartDates.count == 0 || profit_rate.count == 0 {
            return
        }
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
        
        var profitString = ""
        let _profitValue = self.profit_rate[Int(entry.x)][0]
        let _totalRate = self.profit_rate[Int(entry.x)][1]
        if _profitValue < 0 {
            profitString = "-" + formatter.string(from: NSNumber(value: -_profitValue ))!
            self.profit.textColor = .red
        } else {
            profitString = formatter.string(from: NSNumber(value: _profitValue ))!
            self.profit.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
        }
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .percent
        self.profit.text = profitString + "(" + formatter.string(from: NSNumber(value: _totalRate))! + ")"
    }
  
    @IBAction func addButtonTapped(_ sender: Any) {
         delegate?.addButtonTapped()
    }
    
}
