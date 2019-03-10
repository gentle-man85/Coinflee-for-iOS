//
//  FavCoinsViewController.swift
//  Bitcoin
//
//  Created by Alex on 31/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts
import Alamofire

class FavCoinsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var language = LanguageFile()
    var isReloading = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTableView: UIView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering == true {
            return filteredCoins.count
        }
        return favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell") as! favTableViewCell
        
        if favoriteCoins.count == 0 {
            return cell
        }
        var cellKey = favoriteCoins[indexPath.row]
        if isFiltering == true {
            cellKey = filteredCoins[indexPath.row]
        }
        
        cell.numberCell.text = "\(indexPath.row + 1)"
        cell.coinName.text = cellKey.uppercased()
        
        guard let coinDetail = coinList[cellKey],
            let price = JSON(coinDetail)["current_price"].rawString(),
            let dPrice = Double(price),
            let ra = JSON(coinDetail)["price_change_percentage_24h"].rawString(),
            let raV = Double(ra),
            let chartList = JSON(coinDetail)["sparkline_in_7d"]["price"].array,
            chartList.count > 0
        else {
            return cell
        }
        
        cell.smallCoinName.text = coinLabels[cellKey]
        
        if let image = imageList[cellKey] {
            cell.coinImage.image = image
        } else {
            var image: UIImage? = nil
            if let urlStr = JSON(coinDetail)["image"].rawString() {
                DispatchQueue.global().async{
                    do {
                        
                        let url = URL(string: urlStr)
                        if let data = NSData(contentsOf:url! as URL) {
                            image = UIImage(data:data as Data)
                        }
                        
                    }
                    DispatchQueue.main.async(execute: {
                        if image != nil {
                            cell.coinImage.image = image
                            imageList[cellKey] = image
                        }
                    })
                }
            }
        }
   
        let formatter = NumberFormatter()
        formatter.currencyCode = quoteCurrency
        formatter.numberStyle = .currency
    
        if dPrice > 1 {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 6
            formatter.maximumFractionDigits = 6
        }
    
        cell.coinPrice.text = formatter.string(from: NSNumber(value: dPrice ))
        
        cell.coinChart.leftAxis.enabled = false
        cell.coinChart.rightAxis.enabled = false
        cell.coinChart.xAxis.enabled = false
        cell.coinChart.legend.enabled = false
        cell.coinChart.drawGridBackgroundEnabled = false
        cell.coinChart.doubleTapToZoomEnabled = false
        cell.coinChart.highlightPerTapEnabled = false
    
        var chartValList: [Double] = []
        let values = (0..<chartList.count).map { (i) -> ChartDataEntry in
            if let str = chartList[i].rawString(),
                let val = Double(str) {
                chartValList.append(val)
                return ChartDataEntry(x: Double(i), y: val)
            }
            return ChartDataEntry(x: Double(i), y: 0)
        }
        let min = chartValList.min()!
        let max = chartValList.max()!
        let min_0 = min - (max - min) / 5
       
        var bottomValues: [ChartDataEntry] = []
        for i in stride(from:0, to:chartList.count, by: 15 ) {
            bottomValues.append(ChartDataEntry(x: Double(i), y: min_0))
        }
    
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1
        set1.drawValuesEnabled = false
        set1.highlightEnabled = false
    
        if raV > 0.0 {
            set1.setColor(UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0))
        } else {
            set1.setColor(.red)
        }
    
        let set2 = LineChartDataSet(values: bottomValues, label: "DataSet 2")
        set2.drawCirclesEnabled = false
        set2.drawValuesEnabled = false
        set2.highlightEnabled = false
        set2.setColor(.black)
        set2.lineDashLengths = [2, 5]
        set2.lineWidth = 2
    
        let series = LineChartData(dataSets: [set1, set2])
        cell.coinChart.data = series
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "bitcoinDetail") as! DetailViewController
        DvC.getCoin = favoriteCoins[indexPath.row]
        selectedCoin = favoriteCoins[indexPath.row]
        self.navigationController?.pushViewController(DvC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset < 0 && isReloading == false {
            isReloading = true
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
            self.tableView.tableHeaderView = spinner;
            self.loadData()
        }
    }
    
    @IBOutlet weak var AddFirst: UILabel!
    @IBOutlet weak var Clicking: UILabel!
    @IBOutlet weak var Icon: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AddFirst.text = language.localizedString(str: "Add your first icon by")
        Clicking.text = language.localizedString(str: "clicking the")
        Icon.text = language.localizedString(str: "coin")
        tableView.reloadData()
        
        if favoriteCoins.count == 0 {
            tableView.isHidden = true
        }
    }
    
    //@IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 67
    
        var needLoad = false
        for coinName in favoriteCoins {
            if coinNames.contains(coinName) == false {
                needLoad = true
                break;
            }
        }
        if needLoad == true {
            loadData()
        }
    }
    
    func loadData() {
        DispatchQueue.global().async {
            var ids = ""
            for key in favoriteCoins {
                if let coinId = favoriteCoinIds[key] {
                    ids += coinId + ","
                }
            }
            AF.request("https://api.coingecko.com/api/v3/coins/markets",
                       parameters: ["vs_currency": quoteCurrency.lowercased(), "sparkline": "true", "ids": ids])
                .responseJSON { response in
                    guard response.result.isSuccess,
                        let value = response.result.value else{
                            print("Error while fetching tags: \(String(describing: response.result.error))")
                            return
                    }
                    
                    let raw = JSON(value)
                    for (_, value) in raw {
                        if let key = value["id"].rawString(),
                            let symbol = value["symbol"].rawString(),
                            let name = value["name"].rawString()
                        {
                            coinIds[symbol] = key
                            coinList[symbol] = value
                            coinLabels[symbol] = name
                        }
                    }
                  
                    if self.isReloading == true {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self.isReloading = false
                            self.tableView.tableHeaderView = nil
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.1) {
                            self.tableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the index path from the cell that was tapped
        let indexPath = tableView.indexPathForSelectedRow
        // Get the Row of the Index Path and set as index
        let index = indexPath?.row
        // Get in touch with the DetailViewController
        let detailViewController = segue.destination as! DetailViewController
        // Pass on the data to the Detail ViewController by setting it's indexPathRow value
        detailViewController.index = index
    }

    
}
