//
//  SelectCoinDetailViewController.swift
//  Bitcoin
//
//  Created by Team on 04/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectCoinDetailViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var language = LanguageFile()
    @IBOutlet weak var tableView: UITableView!

    var filteredCoins:[String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelecctCell") as! SelectTableViewCell
        
        let cellKey = self.filteredCoins[indexPath.row]
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.coinName.text = coinLabels[cellKey]! + "(\(cellKey.uppercased()))"
        if let image = imageList[cellKey] {
            cell.coinImage.image = image
        } else {
            var image: UIImage? = nil
            if let urlStr = JSON(coinList[cellKey]!)["image"].rawString() {
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCoin = self.filteredCoins[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var cusView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        
        // Do any additional setup after loading the view.
        
        //tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        title = language.localizedString(str: "Select Coin")
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationItem.setHidesBackButton(true, animated: true)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        cusView.backgroundColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        //search bar color clear
        
        let textFiledInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFiledInsideSearchBar?.textColor = UIColor.white
        textFiledInsideSearchBar?.tintColor = UIColor.white
        textFiledInsideSearchBar?.backgroundColor = UIColor(red: 0,green: 55.0/255, blue: 105.0/255, alpha: 1.0)
        searchBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        searchBar.placeholder = language.localizedString(str: "Search your favorite coin")
        searchBar.delegate = self
        self.filteredCoins = coinNames
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredCoins = coinNames.filter({ coinName -> Bool in
            return coinName.lowercased().contains(searchText.lowercased())
        })
        if searchText == "" {
            self.filteredCoins = coinNames
        }
        tableView.reloadData()
    }
    
    @IBAction func onClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
