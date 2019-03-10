//
//  DetailViewController.swift
//  Bitcoin
//
//  Created by Alex on 30/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts
import Alamofire
import MBProgressHUD
import SafariServices


class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ChartViewDelegate, AddButtonDelegate, BuySellButtonDelegate {
    
   var language = LanguageFile()
  
    var index: Int!
    @IBOutlet weak var cusNavView: UIView!
    @IBOutlet weak var starBarButtonItem: UIBarButtonItem!
    
    weak var currentViewController: UIViewController?
    var searchBar = UISearchBar()
    var textView : UILabel!
    var backButtonItem: UIBarButtonItem?
    var barItems: [UIBarButtonItem]?
    var getCoin: String!
    var chartDates: [Double] = []
    var typeDatas: [Double] = []
    var isReloading = false
    
    @IBOutlet weak var coinTypeView: UIView!
    @IBOutlet weak var hButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var wButton: UIButton!
    @IBOutlet weak var mButton: UIButton!
    @IBOutlet weak var msixButton: UIButton!
    @IBOutlet weak var yButton: UIButton!
    @IBOutlet weak var allButton: UIButton!  
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 320
        }
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailHeader") as! DetailTableViewHeaderCell
            
            cell.priceLabel.text = language.localizedString(str: "Price")
            cell.addBtn.setTitle(language.localizedString(str: "Add"), for: .normal)
            cell.delegate = self
            
            if let coinName = selectedCoin {
                cell.coinImage.image = imageList[coinName]
                cell.coinName.text = coinLabels[coinName]
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd, yyyy-ha"
                cell.date.text = dateFormatter.string(from: date)
                
                let formatter = NumberFormatter()
                formatter.currencyCode = quoteCurrency
                formatter.numberStyle = .currency
                
                if let coinDetail = coinList[coinName] {
                    let price = JSON(coinDetail)["current_price"].rawString()!
                    if Double(price)! > 1 {
                        formatter.minimumFractionDigits = 2
                        formatter.maximumFractionDigits = 2
                    } else {
                        formatter.minimumFractionDigits = 6
                        formatter.maximumFractionDigits = 6
                    }
                    cell.price.text = formatter.string(from: NSNumber(value: Double(price)!))
                }
            }
            
            cell.chart.delegate = cell
            cell.chart.leftAxis.enabled = false
            cell.chart.rightAxis.enabled = false
            cell.chart.xAxis.enabled = false
            cell.chart.legend.enabled = false
            cell.chart.drawGridBackgroundEnabled = false
            cell.chart.doubleTapToZoomEnabled = false
            cell.chart.highlightPerTapEnabled = true
            cell.chart.backgroundColor = #colorLiteral(red: 0, green: 0.3558115605, blue: 0.5942655457, alpha: 1)
            cell.chart.highlightValue(nil)
            
            let values = (0..<self.typeDatas.count).map { (i) -> ChartDataEntry in
                let val = self.typeDatas[i]
                return ChartDataEntry(x: Double(i), y: val)
            }
            
            let set1 = LineChartDataSet(values: values, label: "DataSet 1")
            set1.drawCirclesEnabled = false
            set1.lineWidth = 2
            set1.drawValuesEnabled = false
            set1.highlightEnabled = true
            set1.setColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1))
            let data = LineChartData(dataSet: set1)
            cell.chart.data = data
            cell.chartDates = self.chartDates
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailButton") as! DetailTableViewButtonCell
            
            cell.buyBtn.setTitle(language.localizedString(str: "buy"), for: .normal)
            cell.sellBtn.setTitle(language.localizedString(str: "sell"), for: .normal)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! DetailTableViewCell
            
            guard let coinName = selectedCoin,
                  let coinDetail = coinList[coinName] else{
                return cell
            }
            
            let formatter = NumberFormatter()
            formatter.currencyCode = quoteCurrency
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            switch indexPath.row {
            case 2:
                cell.name.text = language.localizedString(str: "1 Day Change")
                if let val = Double(JSON(coinDetail)["price_change_percentage_24h"].rawString()!)
                {
                    if val > 0 {
                        cell.value.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
                    } else {
                        cell.value.textColor = #colorLiteral(red: 0.9901253173, green: 0.08771979135, blue: 0.08272286551, alpha: 1)
                    }
                    formatter.numberStyle = .percent
                    cell.value.text = formatter.string(from: NSNumber(value: val/100))
                }
                break
            case 3:
                cell.name.text = language.localizedString(str: "Market Cap")
                let market = JSON(coinDetail)["market_cap"].rawString()!
                cell.value.text = formatter.string(from: NSNumber(value: Double(market)!))
                break
            case 4:
                cell.name.text = language.localizedString(str: "Volume(24 hours)")
                let _volume = JSON(coinDetail)["total_volume"].rawString()!
                cell.value.text = formatter.string(from: NSNumber(value: Double(_volume)!))
                break
            case 5:
                cell.name.text = language.localizedString(str: "Available Supply")
                let _availiable = JSON(coinDetail)["circulating_supply"].rawString()!
                formatter.numberStyle = .decimal
                cell.value.text = formatter.string(from: NSNumber(value: Double(_availiable)!))
                break
            case 6:
                cell.name.text = language.localizedString(str: "Total Supply")
                let _total = JSON(coinDetail)["total_supply"].rawString()!
                formatter.numberStyle = .decimal
                if let totalVal = Double(_total) {
                    cell.value.text = formatter.string(from: NSNumber(value: totalVal))
                } else {
                    cell.value.text = "?"
                }
                break
            case 7:
                cell.name.text = language.localizedString(str: "Low(24 hours)")
                let _low = JSON(coinDetail)["low_24h"].rawString()!
                if Double(_low)! > 1 {
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                } else {
                    formatter.minimumFractionDigits = 6
                    formatter.maximumFractionDigits = 6
                }
                cell.value.text = formatter.string(from: NSNumber(value: Double(_low)!))
                break
            case 8:
                cell.name.text = language.localizedString(str: "High(24 hours)")
                let _high = JSON(coinDetail)["high_24h"].rawString()!
                if Double(_high)! > 1 {
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                } else {
                    formatter.minimumFractionDigits = 6
                    formatter.maximumFractionDigits = 6
                }
                cell.value.text = formatter.string(from: NSNumber(value: Double(_high)!))
                break
            default:
                break
            }
            
            return cell
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButton.setTitle(language.localizedString(str: "ALL"), for: .normal)
        searchBar.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = PortfolioGradientView(frame: tableView.frame)
        
        onDButton(self)
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.selectedIndex = 0
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        //for search bar
        
        searchBar.showsCancelButton = true
        let textFiledInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFiledInsideSearchBar?.textColor = UIColor.white
        textView = UILabel()
        textView.text = coinLabels[selectedCoin]
        textView.textColor=UIColor.white
        navigationItem.titleView = textView
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.placeholder = language.localizedString(str: "Search your favorite coin")
        backButtonItem = navigationItem.backBarButtonItem
        barItems = navigationItem.rightBarButtonItems
        (searchBar.value(forKey: "cancelButton") as! UIButton).setTitle(language.localizedString(str: "Cancel"), for: .normal)
        //contain implement
        
        coinTypeView.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        
        let cornerRadius = 13
        hButton.layer.cornerRadius = CGFloat(cornerRadius)
        dButton.layer.cornerRadius = CGFloat(cornerRadius)
        wButton.layer.cornerRadius = CGFloat(cornerRadius)
        mButton.layer.cornerRadius = CGFloat(cornerRadius)
        msixButton.layer.cornerRadius = CGFloat(cornerRadius)
        yButton.layer.cornerRadius = CGFloat(cornerRadius)
        allButton.layer.cornerRadius =  CGFloat(cornerRadius)
        
        
        if favoriteCoins.firstIndex(of: getCoin) != nil
        {
            starBarButtonItem.image = UIImage(named: "favorite")
        } else {
            starBarButtonItem.image = UIImage(named: "star")
        }
        //clearing
//
//        hButton.backgroundColor = UIColor(red: 0/255,green: 75.0/255,blue: 142.0/255,alpha: 1.0)
//
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                self.isReloading = false
                self.tableView.tableHeaderView = nil
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.7, execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func loadChartData(days: Int = 1) {
        self.showHUD()
        
        DispatchQueue.global().async {
            if let key = coinIds[selectedCoin] {
                let url = "https://api.coingecko.com/api/v3/coins/" + key + "/market_chart"
                AF.request(url, parameters: ["vs_currency": quoteCurrency, "days": days])
                    .responseJSON { response in
                        guard response.result.isSuccess,
                            let value = response.result.value else{
                                print("Error while fetching tags: \(String(describing: response.result.error))")
                                return
                        }
                        
                        let datas = JSON(value)["prices"]
                        var typeDatas: [Double] = []
                        var dates: [Double] = []
                        
                        for value in datas.array! {
                            if let a = value[1].rawString(),
                                let b = Double(a)
                            {
                                typeDatas.append(b)
                            }
                            if let t = value[0].rawString(),
                                let d = Double(t)
                            {
                                dates.append(d/1000)
                            }
                        }
                        
                        self.chartDates = dates
                        self.typeDatas = typeDatas
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.dismissHUD(isAnimated: true)
                        }
                }
            }
        }
    }
    
    func loadHourChartData() {
        self.showHUD()
        
        DispatchQueue.global().async {
            if let key = coinIds[selectedCoin] {
                let url = "https://api.coingecko.com/api/v3/coins/" + key + "/market_chart"
                AF.request(url, parameters: ["vs_currency": quoteCurrency, "days": 1])
                    .responseJSON { response in
                        guard response.result.isSuccess,
                            let value = response.result.value else{
                                print("Error while fetching tags: \(String(describing: response.result.error))")
                                return
                        }
                        
                        let datas = JSON(value)["prices"]
                        var typeDatas: [Double] = []
                        var dates: [Double] = []
                        
                        if let lastDateString = datas.array?.last?.array?.first?.rawString(),
                            let lastTimeInterval = Double(lastDateString) {
                            
                            let anHourAgo = lastTimeInterval - 3600000.0
                            
                            for value in datas.array! {
                                if let t = value[0].rawString(),
                                    let d = Double(t),
                                    d > anHourAgo
                                {
                                    dates.append(d/1000)
                                    if let a = value[1].rawString(),
                                        let b = Double(a)
                                    {
                                        typeDatas.append(b)
                                    }
                                }
                            }
                            self.chartDates = dates
                            self.typeDatas = typeDatas
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.dismissHUD(isAnimated: true)
                        }
                }
            }
        }
    }
    
    func loadMaxChartData() {
        self.showHUD()
        
        DispatchQueue.global().async {
            if let key = coinIds[selectedCoin] {
                let url = "https://api.coingecko.com/api/v3/coins/" + key + "/market_chart"
                AF.request(url, parameters: ["vs_currency": quoteCurrency, "days": "max"])
                    .responseJSON { response in
                        guard response.result.isSuccess,
                            let value = response.result.value else{
                                print("Error while fetching tags: \(String(describing: response.result.error))")
                                return
                        }
                        
                        let datas = JSON(value)["prices"]
                        var typeDatas: [Double] = []
                        var dates: [Double] = []
                        
                        for value in datas.array! {
                            if let a = value[1].rawString(),
                                let b = Double(a)
                            {
                                typeDatas.append(b)
                            }
                            if let t = value[0].rawString(),
                                let d = Double(t)
                            {
                                dates.append(d/1000)
                            }
                        }
                        
                        self.chartDates = dates
                        self.typeDatas = typeDatas
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.dismissHUD(isAnimated: true)
                        }
                }
            }
        }
    }    
    
    func showHUD(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.offset.y = -self.view.frame.size.height / 2 + 200
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
        loadHourChartData()
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
        loadMaxChartData()
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
    
    func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setRightBarButtonItems(nil, animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
        self.searchBar.alpha = 1
        self.searchBar.becomeFirstResponder()
    
    }
    
    func hideSearchBar() {
        navigationItem.setRightBarButtonItems(barItems, animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
        textView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.textView.alpha = 1
            self.navigationItem.rightBarButtonItems = self.barItems
            self.navigationItem.titleView = self.textView
        }, completion: { finished in
        })
    }
    
    
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
//        showSearchBar()
        self.navigationController?.popViewController(animated: true)
        let controller = self.navigationController?.viewControllers.first as! homeNavi
        controller.showSearchBar()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        hideSearchBar()
    }
    
    func addButtonTapped() {
        self.navigationController?.popViewController(animated: true)
        let controller = self.navigationController?.viewControllers.first as! homeNavi
        controller.hideSearchBar()
        controller.selectedNav = 2
    }
    
    func BuyButtonTapped() {
        let urlString = "https://changelly.com/?ref_id=qso2bg0jqpzvom2n"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
    
    func SellButtonTapped() {
        let urlString = "https://changelly.com/?ref_id=qso2bg0jqpzvom2n"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
  
   
    @IBAction func onFavorite(_ sender: Any) {
        if let idx = favoriteCoins.firstIndex(of: getCoin)
        {
            favoriteCoins.remove(at: idx)
            starBarButtonItem.image = UIImage(named: "star")
        } else {
            favoriteCoins.append(getCoin)
            favoriteCoinIds[getCoin] = coinIds[getCoin]
            starBarButtonItem.image = UIImage(named: "favorite")
        }
        UserDefaults.standard.set(favoriteCoins, forKey: "favoriteCoins")
        UserDefaults.standard.set(favoriteCoinIds, forKey: "favoriteCoinIds")
    }
    
}
