//
//  PortfolioViewController.swift
//  Bitcoin
//
//  Created by Alex on 31/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts
import Alamofire
import MBProgressHUD
import PromiseKit

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
var totalPortfolioValue: Double = 0.0
class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddButtonDelegate {
    
    var language = LanguageFile()
    var isReloading = false
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 365
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tradeCoinNames.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioHeaderCell") as! portfolioTableViewHeaderCell
            
            cell.TotalPortfolio.text = language.localizedString(str: "Total Portfolio Value")
            cell.Name.text = language.localizedString(str: "Name")
            cell.Price1.text = language.localizedString(str: "Price")
            cell.Profit1.text = language.localizedString(str: "Profit/Loss")
            cell.Total1.text = language.localizedString(str: "Total")
            cell.AddButton.setTitle(language.localizedString(str: "Add"), for: .normal)
            cell.delegate = self
           
            let _date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy-ha"
            cell.date.text = dateFormatter.string(from: _date)
            
            let formatter = NumberFormatter()
            formatter.currencyCode = quoteCurrency
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            if tradeCoinNames.count == 0 {
                cell.chart.data = nil
                cell.chart.delegate = nil
                cell.price.text = formatter.string(from: NSNumber(value: 0.0))
                let profitString = formatter.string(from: NSNumber(value: 0.0 ))
                formatter.numberStyle = .percent
                cell.profit.text = profitString! + "(" + formatter.string(from: NSNumber(value: 0.0))! + ")"
                cell.profit.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
                return cell
            }
            for key in tradeCoinNames {
                if coinList[key] == nil {
                    return cell
                }
            }
          
            var _totalValue = 0.0
            var _profitValue = 0.0
            var _curTotalValue = 0.0
            
            for (_, key) in tradeCoinNames.enumerated() {
                if let coinDetail = coinList[key],
                    let priceStr = JSON(coinDetail)["current_price"].rawString(),
                    let price = Double(priceStr)
                {
                    var total = 0.0
                    var amount = 0.0
                    if let tradeDetails = tradeCoins[key] {
                        for tradeDetail in tradeDetails {
                            if let tradeAmount = tradeDetail["amount"] {
                                amount += tradeAmount
                                if let tradePrice = tradeDetail["price"] {
                                    total += tradeAmount * tradePrice
                                }
                            }
                            
                        }
                    }
                    
                    _totalValue += total
                    _profitValue += price * amount - total
                    _curTotalValue += price * amount
                    
                }
            }
            totalPortfolioValue = _totalValue
            var _totalRate = _profitValue / _totalValue
            
            if Double(_totalValue) > 1 {
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
            } else {
                formatter.minimumFractionDigits = 6
                formatter.maximumFractionDigits = 6
            }
            cell.price.text = formatter.string(from: NSNumber(value: _curTotalValue))!
            
            if _totalRate.isNaN == true {
                _totalRate = 0.0
            }
            var profitString = ""
            if _profitValue < 0 {
                profitString = "-" + formatter.string(from: NSNumber(value: -_profitValue ))!
                cell.profit.textColor = .red
            } else {
                profitString = formatter.string(from: NSNumber(value: _profitValue ))!
                cell.profit.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
            }
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.numberStyle = .percent
            cell.profit.text = profitString + "(" + formatter.string(from: NSNumber(value: _totalRate))! + ")"
            ///////////////////////draw Chart
            let values = (0..<self.totalPrices.count).map { (i) -> ChartDataEntry in
                let val = self.totalPrices[i]
                return ChartDataEntry(x: Double(i), y: val)
            }
            cell.chart.highlightValue(nil)
            
            let set1 = LineChartDataSet(values: values, label: "DataSet 1")
            set1.drawCirclesEnabled = false
            set1.lineWidth = 2
            set1.drawValuesEnabled = false
            set1.highlightEnabled = true
            
            set1.setColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1))
            
            let data = LineChartData(dataSet: set1)
            
            cell.chart.data = data
            cell.chartDates = self.chartDates
            cell.profit_rate = self.profit_rate
            
            cell.chart.delegate = cell
            
            return cell
        }
        ////////////////////////////////////////////table cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell") as! portfolioTableViewCell
        
        let cellKey = tradeCoinNames[indexPath.row-1]
        cell.coinName.text = cellKey.uppercased()
        
        guard let coinDetail = coinList[cellKey],
            let priceStr = JSON(coinDetail)["current_price"].rawString(),
            let price = Double(priceStr)
        else {
            return cell
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
        
        if price > 1 {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 6
            formatter.maximumFractionDigits = 6
        }
        cell.coinPrice.text = formatter.string(from: NSNumber(value: price ))
        
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .percent
        
        var total = 0.0
        var amount = 0.0
        if let tradeDetails = tradeCoins[cellKey] {
            for tradeDetail in tradeDetails {
                if let tradeAmount = tradeDetail["amount"] {
                    amount += tradeAmount
                    if let tradePrice = tradeDetail["price"] {
                        total += tradeAmount * tradePrice
                    }
                }
                
            }
        }
        
        let profit = price * amount - total
        let rate = profit / total
        
        cell.coinRate.text = formatter.string(from: NSNumber(value: rate))
        if rate > 0 {
            cell.coinRate.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
            cell.coinProfit.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
        } else {
            cell.coinRate.textColor = UIColor.red
            cell.coinProfit.textColor = UIColor.red
        }
        
        formatter.numberStyle = .currency
       
        cell.coinProfit.text = formatter.string(from: NSNumber(value: profit))!
        cell.coinTotalPrice.text = formatter.string(from: NSNumber(value: price * amount))!
        
        formatter.numberStyle = .decimal
        cell.coinAmount.text = formatter.string(from: NSNumber(value: amount))!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            indexPath.row != 0
        {
            tradeCoinNames.remove(at: indexPath.row-1)
            UserDefaults.standard.set(tradeCoinNames, forKey: "tradeCoinNames")
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }

        let navV = self.tabBarController?.viewControllers?[0] as! UINavigationController
        navV.popToRootViewController(animated: false)

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "bitcoinDetail") as! DetailViewController
        newViewController.getCoin = tradeCoinNames[indexPath.row-1]
        selectedCoin = tradeCoinNames[indexPath.row-1]

        navV.show(newViewController, sender: self)
        self.tabBarController?.selectedIndex = 0
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
    
    var chartDates: [Double] = []
    var profit_rate: [[Double]] = []
    var totalPrices: [Double] = []
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var hButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var wButton: UIButton!
    @IBOutlet weak var mButton: UIButton!
    @IBOutlet weak var msixButton: UIButton!
    @IBOutlet weak var yButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allButton.setTitle(language.localizedString(str: "ALL"), for: .normal)
        
        onDButton(self)
        
        tableView.reloadData()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.selectedIndex = 1       
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundView = PortfolioGradientView(frame: tableView.frame)
     
        let cornerRadius = 13
        hButton.layer.cornerRadius = CGFloat(cornerRadius)
        dButton.layer.cornerRadius = CGFloat(cornerRadius)
        wButton.layer.cornerRadius = CGFloat(cornerRadius)
        mButton.layer.cornerRadius = CGFloat(cornerRadius)
        msixButton.layer.cornerRadius = CGFloat(cornerRadius)
        yButton.layer.cornerRadius = CGFloat(cornerRadius)
        allButton.layer.cornerRadius =  CGFloat(cornerRadius)
        

        var needLoad = false
        for coinName in tradeCoinNames {
            if coinNames.contains(coinName) == false {
                needLoad = true
                break;
            }
        }
        if needLoad == true {
            loadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset < 0 && isReloading == false {
            isReloading = true
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
            spinner.color = .white
            self.tableView.tableHeaderView = spinner;
            self.loadData()
        }
    }
    
    func loadData() {
        DispatchQueue.global().async {
            var ids = ""
            for key in tradeCoinNames {
                if let coinId = tradeCoinIds[key] {
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
    
    func loadChartData(days: Int = 1) {
        
        if tradeCoinNames.count == 0 {
            return
        }
        
        self.showHUD()
        var coinStartTime = 0.0
        var promises: [Promise<[JSON]>] = []
        var dayString: String = ""
        
        switch days {
        case 0: //hourly
            dayString = "1"
            break
        case 367: //max
            dayString = "max"
            break
        default:
            dayString = String(days)
        }
       
        for tradeCoin in tradeCoinNames {
            if let key = tradeCoinIds[tradeCoin] {
                let url = "https://api.coingecko.com/api/v3/coins/" + key + "/market_chart"
                 let promise = Promise<[JSON]>() { seal in
                        DispatchQueue.global().async {
                            AF.request(url, parameters: ["vs_currency": quoteCurrency, "days": dayString])
                                .responseJSON { response in
                                    if let result = response.result.value {
                                        let json = JSON(result)
                                        if let data = json["prices"].array {
                                            seal.fulfill(data)
                                        } else {
                                            seal.fulfill([])
                                        }
                                    }
                            }
                        }
                }
                promises.append(promise)
                ////////////////
                if let tradeCoinDetails = tradeCoins[tradeCoin] {
                    for tradeCoinDetail in tradeCoinDetails {
                        if let tradeTime = tradeCoinDetail["time"] {
                            if coinStartTime == 0.0 || coinStartTime > tradeTime {
                                coinStartTime = tradeTime
                            }
                        }
                    }
                }
            }
        }
        
        when(resolved: promises).done { _ in
           
            DispatchQueue.global().async {
                
                var resultMaxCount = 0
                var coinPrices:[String:[Double]] = [:]
                var dates: [Double] = []
                //////////////filter response data greater than coinStartTime every trade coins
                for (index, key) in tradeCoinNames.enumerated() {
                    if let result = promises[index].value,
                        let resultArr = JSON(result).array {
                        
                        var conditionCount = 0
                        var coinDates:[Double] = []
                        coinPrices[key] = []
                        
                        for value in resultArr {
                            
                            if let timeStr = value[0].rawString(),
                                let dTime = Double(timeStr),
                                dTime/1000 >= coinStartTime {
                                
                                conditionCount += 1
                                coinDates.append(dTime/1000)
                                
                                let priceStr = value[1].rawString() ?? ""
                                let dPrice = Double(priceStr) ?? 0.0
                                coinPrices[key]?.append(dPrice)
                            }
                        }
                        
                        if resultMaxCount < conditionCount {
                            resultMaxCount = conditionCount
                            dates = coinDates
                        }
                    }
                }
                ////////////////each coin price count must be equal resultMaxCount
                for (key, value) in coinPrices {
                    if value.count < resultMaxCount {
                        for  _ in value.count..<resultMaxCount {
                            if let lastPrice = value.last {
                                coinPrices[key]?.append(lastPrice)
                            } else if let coinDetail = coinList[key],
                                let priceStr = JSON(coinDetail)["current_price"].rawString(),
                                let price = Double(priceStr) {
                                coinPrices[key]?.append(price)
                            } else {
                                coinPrices[key]?.append(0.0)
                            }
                        }
                    }
                }
                /////////////////make chartData,
                var totalPrices:[Double] = []
                var profitRate: [[Double]] = []
                
                for i in 0..<resultMaxCount {
                    var total = 0.0
                    var staticTotal = 0.0
                    var profit = 0.0
                    let curTime = dates[i]
                    
                    for (key, value) in coinPrices {

                        if  tradeCoinNames.contains(key),
                            let tradeDetails = tradeCoins[key]
                        {
                            for tradeDetail in tradeDetails {
                                if let tradePrice = tradeDetail["price"],
                                    let tradeAmount = tradeDetail["amount"],
                                    let tradeTime = tradeDetail["time"],
                                    tradeTime <= curTime
                                {
                                    total += value[i] * tradeAmount
                                    staticTotal += tradePrice * tradeAmount
                                    profit += value[i] * tradeAmount - tradePrice * tradeAmount
                                }
                            }
                        }
                    }
                    
                    totalPrices.append(total)
                    profitRate.append([profit, profit/staticTotal])
                }
                ////////////////////////////////////// 1 Day Process
                if days == 1,
                    dates.count > 0,
                    totalPrices.count > 0,
                    profitRate.count > 0
                    {
                    var prevDate = dates[0]
                    var tempDates:[Double] = [dates[0]]
                    var tempTotal:[Double] = [totalPrices[0]]
                    var tempProfit_rate:[[Double]] = [profitRate[0]]
                    for i in 1..<dates.count {
                        if dates[i] >= prevDate + 3600 {
                            prevDate = dates[i]
                            tempDates.append(dates[i])
                            tempTotal.append(totalPrices[i])
                            tempProfit_rate.append(profitRate[i])
                        }
                    }
                    dates = tempDates
                    totalPrices = tempTotal
                    profitRate = tempProfit_rate
                }
                ////////////////////////////////// 1 Hour Process
                if days == 0 {
                    let prevDate = Date().timeIntervalSince1970 - 3600
                    var tempDates:[Double] = []
                    var tempTotal:[Double] = []
                    var tempProfit_rate:[[Double]] = []
                    for i in 1..<dates.count {
                        if dates[i] >= prevDate {
                            tempDates.append(dates[i])
                            tempTotal.append(totalPrices[i])
                            tempProfit_rate.append(profitRate[i])
                        }
                    }
                    dates = tempDates
                    totalPrices = tempTotal
                    profitRate = tempProfit_rate
                }
                
                //////////////1y, 6m error process
                if totalPrices.count <= 2 {
                    var total = 0.0
                    var staticTotal = 0.0
                    var profit = 0.0
                    
                    for key in tradeCoinNames {
                        if let coinDetail = coinList[key],
                            let priceStr = JSON(coinDetail)["current_price"].rawString(),
                            let price = Double(priceStr),
                            let value = tradeCoins[key]
                        {
                            for tradeDetail in value {
                                if let tradePrice = tradeDetail["price"],
                                    let tradeAmount = tradeDetail["amount"]
                                {
                                    total += price * tradeAmount
                                    staticTotal += tradePrice * tradeAmount
                                    profit += price * tradeAmount - tradePrice * tradeAmount
                                }
                            }
                        }
                    }
                    dates = [Date().timeIntervalSince1970 - 3600, Date().timeIntervalSince1970]
                    totalPrices = [total, total]
                    profitRate = [[profit, profit/staticTotal], [profit, profit/staticTotal]]
                }
                ///////////////////////
                self.chartDates = dates
                self.totalPrices = totalPrices
                self.profit_rate = profitRate
    //            print(dates)
    //            print(totalPrices)
    //            print(self.profit_rate)
          
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.dismissHUD(isAnimated: true)
                }
            
            }
        }
    }
    
    
    func showHUD(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.offset.y = -self.view.frame.size.height / 2 + 220
    }
    
    func dismissHUD(isAnimated:Bool) {
        MBProgressHUD.hide(for: self.view, animated: isAnimated)
    }
    
    @IBAction func onDButton(_ sender: Any) {
        
        buttonReset()
        dButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 1)
    }
    @IBAction func onHButton(_ sender: Any) {
        buttonReset()
        hButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 0)
    }
    @IBAction func onWButton(_ sender: Any) {
        buttonReset()
        wButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 7)
    }
    
    @IBAction func onMButton(_ sender: Any) {
        buttonReset()
        mButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 30)
    }
    
    
    @IBAction func onMsixButton(_ sender: Any) {
        buttonReset()
        msixButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 180)
    }
    
    @IBAction func onYButton(_ sender: Any) {
        buttonReset()
        yButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 365)
    }
    
    @IBAction func onAllButton(_ sender: Any) {
        buttonReset()
        allButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
        loadChartData(days: 367)
    }
    
    
    private func buttonReset()
    {
        hButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        dButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        wButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        mButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        msixButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        yButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        allButton.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
    }
    
    func addButtonTapped() {
        selectedCoin = "btc"
        let navV = self.tabBarController?.viewControllers?[0] as! UINavigationController
        navV.popToRootViewController(animated: false)
        let view = navV.viewControllers.first as! homeNavi
        view.selectedNav = 2
        self.tabBarController?.selectedIndex = 0
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


@IBDesignable
class PortfolioGradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0) { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.25 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.5 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
