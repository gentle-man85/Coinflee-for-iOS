//
//  homeNavi.swift
//  Bitcoin
//
//  Created by Alex on 30/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

var isFiltering = false
var filteredCoins: [String] = []
var market_cap = ""

class homeNavi: UIViewController, UISearchBarDelegate {

    weak var currentViewController: UIViewController?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cusNavView: UIView!
    var searchBar = UISearchBar()
    var textView : UILabel!
    var searchBarButtonItem: UIBarButtonItem?
    var usdButtonItem: UIBarButtonItem?
    
    var selectedNav: Int = 1
    var curNavbar = 1
    
    var getTradeType: String!
    let language = LanguageFile()
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        allButton.setTitle(language.localizedString(str: "all"), for: .normal)
        addButton.setTitle(language.localizedString(str: "add"), for: .normal)
        favButton.setTitle(language.localizedString(str: "favorites"), for: .normal)
        usdButtonItem?.title = quoteCurrency
        (searchBar.value(forKey: "cancelButton") as! UIButton).setTitle(language.localizedString(str: "Cancel"), for: .normal)
        
        searchBar.placeholder = language.localizedString(str: "Search your favorite coin")
        
        if(selectedNav == 2)
        {
            showAdd(true)
            print("2")
        } else {
            print("1")
        }
        if curNavbar == 1 {
            textView.text = language.localizedString(str: "MC") + ": $ " + market_cap
        } else if curNavbar == 2 {
            textView.text = language.localizedString(str: "Add Transaction")
        } else if curNavbar == 3 {
            textView.text = language.localizedString(str: "Favorites")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curNavbar = 1
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentAll")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
        
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.white
        cusNavView.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        
        searchBar.showsCancelButton = true
        (searchBar.value(forKey: "cancelButton") as! UIButton).setTitle(language.localizedString(str: "Cancel"), for: .normal)
        
        let textFiledInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFiledInsideSearchBar?.textColor = UIColor.white
        textView = UILabel()
//        textView.text = language.localizedString(str: "MC") + ": $" + market_cap
        textView.textColor=UIColor.white
        textView.textAlignment = NSTextAlignment.center
        textView.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = textView
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.placeholder = language.localizedString(str: "Search your favorite coin")
        searchBarButtonItem = navigationItem.rightBarButtonItem
        usdButtonItem = navigationItem.leftBarButtonItem
        
        
        allButton.setTitleColor(UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0), for: .normal)
        allButton.setImage(UIImage(named: "all_selected"), for: .normal)
        
        loadMarketCap()
        
        tradeCoinNames = UserDefaults.standard.object(forKey: "tradeCoinNames") as? [String] ?? [String]()
        tradeCoins = UserDefaults.standard.object(forKey: "tradeCoins") as? [String:[[String:Double]]] ?? [:]
        tradeCoinIds = UserDefaults.standard.object(forKey: "tradeCoinIds") as? [String: String] ?? [:]
        
        favoriteCoins = UserDefaults.standard.array(forKey: "favoriteCoins") as? [String] ?? []
        favoriteCoinIds = UserDefaults.standard.dictionary(forKey: "favoriteCoinIds") as? [String: String] ?? [:]
        
//        proversionType = UserDefaults.standard.integer(forKey: "proversionType")

//        var _totalValue = 0.0
//        for value in tradeCoins {
//            _totalValue += value["totalPrice"]!
//        }
//        totalPortfolioValue = _totalValue
        
        
        //        if totalPortfolioValue > 1000 && proversionType == 0 {
        
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "upgradeToPro") as! UpgradeProViewController
            
            newViewController.modalPresentationStyle = .popover
            newViewController.modalTransitionStyle = .coverVertical
            self.present(newViewController, animated: true, completion: nil)
        //        }
        
    }
    
   
    func loadMarketCap() {
        DispatchQueue.global().async {
            let headers: HTTPHeaders = [
                "X-CMC_PRO_API_KEY": "3abf2f1b-9fc5-44d7-8ceb-109eb3dff303"
            ]
            AF.request("https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest",
                       parameters: ["convert": quoteCurrency], headers: headers)
                .responseJSON { response in
                    guard response.result.isSuccess,
                        let value = response.result.value else{
                            print("Error while fetching tags: \(String(describing: response.result.error))")
                            return
                    }
                    
                    let raw = JSON(value)["data"]["quote"]
                    let market = JSON(raw)[quoteCurrency]["total_market_cap"]
                    if let mrk = market.rawString(),
                        let dmark = Double(mrk)
                        {
                        let formatter = NumberFormatter()
                        formatter.locale = Locale(identifier: "en_US")
                        formatter.numberStyle = .decimal
                        formatter.minimumFractionDigits = 2
                        formatter.maximumFractionDigits = 2
                        
                        market_cap = formatter.string(from: NSNumber(value: dmark))!
                        self.textView.text = self.language.localizedString(str: "MC") + ": $ " + market_cap
                        self.textView.sizeToFit()
//                        print("loadMarketCap")
                    }
            }
        }
        
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        showSearchBar()
    }
    
    
    func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setLeftBarButton(nil, animated: true)
        self.searchBar.alpha = 1
        self.searchBar.becomeFirstResponder()
        searchBar.text = ""
       
        if curNavbar == 1 {
            filteredCoins = coinNames
        } else if curNavbar == 3 {
            filteredCoins = favoriteCoins
        } else if curNavbar == 2 {
            filteredCoins = coinNames
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentAll")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }
        isFiltering = true
    }
    
    func hideSearchBar() {
        isFiltering = false
        navigationItem.setRightBarButton(searchBarButtonItem, animated: true)
        navigationItem.setLeftBarButton(usdButtonItem, animated: true)
        textView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.textView.alpha = 1
            self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
            self.navigationItem.titleView = self.textView
        }, completion: { finished in
        })
        if curNavbar == 1 {
            let curViewController = self.currentViewController as! AllCoinsViewController
            curViewController.tableView.reloadData()
        } else if curNavbar == 3 {
            let curViewController = self.currentViewController as! FavCoinsViewController
            curViewController.tableView.reloadData()
        } else if curNavbar == 2 {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentAdd") as! AddCoinsViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            newViewController.getTradeType = getTradeType
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if curNavbar == 1 || curNavbar == 2 {
            filteredCoins = coinNames.filter({ coinName -> Bool in
                return coinName.lowercased().contains(searchText.lowercased())
            })
            if searchText == "" {
                filteredCoins = coinNames
            }
            let curViewController = self.currentViewController as! AllCoinsViewController
            curViewController.tableView.tableFooterView = nil
            curViewController.tableView.reloadData()
        } else if curNavbar == 3 {
            filteredCoins = favoriteCoins.filter({ coinName -> Bool in
                return coinName.lowercased().contains(searchText.lowercased())
            })
            if searchText == "" {
                filteredCoins = favoriteCoins
            }
            let curViewController = self.currentViewController as! FavCoinsViewController
            curViewController.tableView.reloadData()
        }
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }
    
    private func resetAllButton()
    {
        allButton.setTitleColor(UIColor.white, for: .normal)
        allButton.setImage(UIImage(named: "all"), for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.setImage(UIImage(named: "add"), for: .normal)
        favButton.setTitleColor(UIColor.white, for: .normal)
        favButton.setImage(UIImage(named: "fav"), for: .normal)
        
        selectedNav = 1
    }
    
    @IBAction func showAll(_ sender: Any) {
        if isFiltering == true {
            return
        }
        curNavbar = 1
        resetAllButton()
        
        allButton.setTitleColor(UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0), for: .normal)
        allButton.setImage(UIImage(named: "all_selected"), for: .normal)
        
        textView.text = language.localizedString(str: "MC") + ": $ " + market_cap
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentAll")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
        
        loadMarketCap()
    }
    
    @IBAction func showAdd(_ sender: Any) {
        if isFiltering == true {
            return
        }
        curNavbar = 2
        resetAllButton()
        if let parentInvoke = sender as? Bool,
            parentInvoke == true {            
        } else {
                self.getTradeType = nil
        }
        
        addButton.setTitleColor(UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0), for: .normal)
        addButton.setImage(UIImage(named: "add_selected"), for: .normal)
        
        textView.text = language.localizedString(str: "Add Transaction")
        
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentAdd") as! AddCoinsViewController
       
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false

        newViewController.getTradeType = getTradeType
        
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
    }
    
    @IBAction func showFav(_ sender: Any) {
        if isFiltering == true {
            return
        }
        curNavbar = 3
        resetAllButton()
        
        favButton.setTitleColor(UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0), for: .normal)
        favButton.setImage(UIImage(named: "fav_selected"), for: .normal)
        
        textView.text = language.localizedString(str: "Favorites")
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentFav")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
    }
    
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        self.addChild(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParent()
                                    newViewController.didMove(toParent: self)
        })
    }
    
    
}
