//
//  AllCoinsViewController.swift
//  Bitcoin
//
//  Created by Alex on 30/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD
import Charts

var coinNames: [String] = []
var coinIds: [String: String] = [:]
var coinLabels: [String: String] = [:]
var coinList: NSMutableDictionary = [:]
var imageList: [String:UIImage] = [:]

var chartDatas: [String: [Double]] = [:]

var quoteCurrency = "USD"
var preQuote = ""
var selectedCoin: String!

var favoriteCoins: [String] = []
var favoriteCoinIds: [String: String] = [:]

var tradeCoinNames: [String] = []
var tradeCoinIds: [String: String] = [:]
var tradeCoins:[String: [[String:Double]]] = [:]

var page_number = 1
var allCoinLoading = false

class AllCoinsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    var _timer: Timer!
    var _mbprogress_hide_status: Bool!
    var isShowAllCoins = false
    
    var isReloading = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if isFiltering == true {
            return filteredCoins.count
        }
        
        return coinNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell") as! coinTableViewCell
        
            var cellKey = coinNames[indexPath.row]
            if isFiltering == true {
                cellKey = filteredCoins[indexPath.row]
            }
        
            cell.numberCell.text = "\(indexPath.row + 1)"
            if let coinDetail = coinList[cellKey] {
                cell.coinName.text = JSON(coinDetail)["symbol"].rawString()?.uppercased()
                cell.smallCoinName.text = JSON(coinDetail)["name"].rawString()
                //            cell.coinRate.text = JSON(coinDetail)["price_change_percentage_24h"].rawString()! + " %"
                
                if let price = JSON(coinDetail)["current_price"].rawString(),
                   let dPrice = Double(price) {
                   
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
                }
                
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
                                    imageList[cellKey] = image
                                    cell.coinImage.image = image
                                }
                            })
                        }
                    }
                    //////////////////////////////////
                    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                    let nameLabel = UILabel(frame: frame)
                    nameLabel.textAlignment = .center
                    nameLabel.backgroundColor = .lightGray
                    nameLabel.textColor = .white
                    nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    nameLabel.text = JSON(coinDetail)["symbol"].rawString()
                    UIGraphicsBeginImageContext(frame.size)
                    if let currentContext = UIGraphicsGetCurrentContext() {
                        nameLabel.layer.render(in: currentContext)
                        let nameImage = UIGraphicsGetImageFromCurrentImageContext()
                        cell.coinImage.image = nameImage
                    }
                    /////////////////////////////
                }
                cell.coinChart.leftAxis.enabled = false
                cell.coinChart.rightAxis.enabled = false
                cell.coinChart.xAxis.enabled = false
                cell.coinChart.legend.enabled = false
                cell.coinChart.drawGridBackgroundEnabled = false
                cell.coinChart.doubleTapToZoomEnabled = false
                cell.coinChart.highlightPerTapEnabled = false
                
                if let chartList = JSON(coinDetail)["sparkline_in_7d"]["price"].array,
                    chartList.count > 0
                {
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
                    //            let bottomValues = (0..<chartList.count).map { (i) -> ChartDataEntry in
                    //                return ChartDataEntry(x: Double(i), y: min_0)
                    //            }
                    var bottomValues: [ChartDataEntry] = []
                    
                    for i in stride(from:0, to:chartList.count, by: 15 ) {
                        bottomValues.append(ChartDataEntry(x: Double(i), y: min_0))
                    }
                    
                    let set1 = LineChartDataSet(values: values, label: "DataSet 1")
                    set1.drawCirclesEnabled = false
                    set1.lineWidth = 1
                    set1.drawValuesEnabled = false
                    set1.highlightEnabled = false
                    
                    let ra = JSON(coinDetail)["price_change_percentage_24h"].rawString()!
                    let raV = Double(ra)
                    if raV! > 0.0 {
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
                }
                
            }
        
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "bitcoinDetail") as! DetailViewController
        DvC.getCoin = coinNames[indexPath.row]
        selectedCoin = coinNames[indexPath.row]
        if isFiltering == true {
            DvC.getCoin = filteredCoins[indexPath.row]
            selectedCoin = filteredCoins[indexPath.row]
        }
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
    
    @IBOutlet weak var tableView: UITableView!
    
   
    func showHUD(){
        self._mbprogress_hide_status = false
        if let parentController = self.parent?.parent?.parent as? UITabBarController {
            MBProgressHUD.showAdded(to: (parentController.view)!, animated: true)
        }
        
        
    }
    
    
    func dismissHUD(isAnimated:Bool) {
        if self._mbprogress_hide_status == false {
            self._mbprogress_hide_status = true
            if let parentController = self.parent?.parent?.parent as? UITabBarController {
                MBProgressHUD.hide(for: (parentController.view)!, animated: isAnimated)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if quoteCurrency != preQuote {
            self.showHUD()
            self.tableView.tableFooterView = nil
            self.tableView.reloadData()
            self.isShowAllCoins = false
            preQuote = quoteCurrency
        } else {
            self.tableView.reloadData()
        }

        _timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        selectedCoin = "btc"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 67

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _timer.invalidate()
    }
    
    @objc func loadData() {
        if let parentHome = parent as? homeNavi {
            parentHome.loadMarketCap()
        }
        DispatchQueue.global().async {
            
        AF.request("https://api.coingecko.com/api/v3/coins/markets",
                   parameters: ["vs_currency": quoteCurrency.lowercased(), "per_page": 250, "page": page_number, "sparkline": "true"])
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
                        if coinNames.contains(symbol) == false {
                            coinNames.append(symbol)
                        }
                        coinIds[symbol] = key
                        coinList[symbol] = value
                        coinLabels[symbol] = name
                    }
                }
                
                DispatchQueue.main.async {
                    
                    if self.isShowAllCoins == false && isFiltering == false {
                        let showAllCoinsBtn = UIButton(type: .custom)
                        showAllCoinsBtn.setTitle("Show All Coins", for: .normal)
                        showAllCoinsBtn.addTarget(self, action: #selector(self.loadingAllCoins), for: .touchUpInside)
                        showAllCoinsBtn.setTitleColor(.white, for: .normal)
                        showAllCoinsBtn.backgroundColor = .blue
                        showAllCoinsBtn.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 30)
                        self.tableView.tableFooterView = showAllCoinsBtn
                    }
                    if self.isReloading == true {
                        self.isReloading = false
                        self.tableView.tableHeaderView = nil
                    }
                    self.dismissHUD(isAnimated: true)
                    self.tableView.reloadData()
                }
            }          
            
        }
    }
    
    @objc func loadingAllCoins() {
        self.isShowAllCoins = true
        allCoinLoading = true
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        self.tableView.tableFooterView = spinner;
        
        _timer.invalidate()
//        parent!.navigationItem.leftBarButtonItem?.isEnabled = false
//        parent!.navigationItem.leftBarButtonItem?.title = "Loading..."
//
        page_number += 1
        loadPageCoins()
    }
    
    func loadPageCoins() {
        DispatchQueue.global().async {
        AF.request("https://api.coingecko.com/api/v3/coins/markets",
                   parameters: ["vs_currency": quoteCurrency.lowercased(), "per_page": 250, "page": page_number, "sparkline": "true"])
            .responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else{
                        print("Error while fetching tags: \(String(describing: response.result.error))")
                        return
                }
                
                let raw = JSON(value)
                if raw.array?.count == 0 {
                    self.tableView.tableFooterView = nil
//                    self.parent!.navigationItem.leftBarButtonItem?.isEnabled = true
//                    self.parent!.navigationItem.leftBarButtonItem?.title = quoteCurrency
                    print("end")
                } else {
                    
                    for (_, value) in raw {
                        if let key = value["id"].rawString(),
                           let symbol = value["symbol"].rawString(),
                           let name = value["name"].rawString(),
                           coinNames.contains(symbol) == false
                        {
                            coinNames.append(symbol)
                            coinIds[symbol] = key
                            coinList[symbol] = value
                            coinLabels[symbol] = name
                        }
                    }
                    
                    page_number += 1
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    print(page_number)
                    if allCoinLoading == true {
                         self.loadPageCoins()
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
        // Pass on the data to the Detail ViewController by setting it"s indexPathRow value
        detailViewController.index = index
    }

}
