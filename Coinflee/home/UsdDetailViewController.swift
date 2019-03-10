//
//  UsdDetailViewController.swift
//  Bitcoin
//
//  Created by Alex on 03/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import Foundation

class MyData {
    class Entry {
        let first : String
        let last : String
        init(first : String, last : String) {
            self.first = first
            self.last = last
        }
    }
    
    let currencies = [
        Entry(first: "US Dollar", last: "USD"),
        Entry(first: "Australian Dollar", last: "AUD"),
        Entry(first: "Brazilian Real", last: "BRL"),
        Entry(first: "British Pound Sterling", last: "GBP"),
        Entry(first: "Canadian Dollar", last: "CAD"),
        Entry(first: "Chinese Yuan", last: "CNY"),
        Entry(first: "Euro", last: "EUR"),
        Entry(first: "Mexico Peso", last: "MXN")
    ]
    
}

var prevSelected : IndexPath = IndexPath(row: 0,section: 0)

class UsdDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var language = LanguageFile()
    @IBOutlet weak var tableView: UITableView!
    let data = MyData()
    
    @IBOutlet weak var Default1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Default1.text = language.localizedString(str: "Default Currency")
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        allCoinLoading = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell") as! CurrencyTableViewCell
        
        cell.firstLabel.text = language.localizedString(str:  data.currencies[indexPath.row].first )
        cell.lastLabel.text = data.currencies[indexPath.row].last
        if indexPath.row == prevSelected.row {
            cell.imageCheck.isHidden = false
            prevSelected = indexPath
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CurrencyTableViewCell
        let precell = tableView.cellForRow(at: prevSelected) as! CurrencyTableViewCell
        
        precell.imageCheck.isHidden = true
        cell.imageCheck.isHidden = false
        prevSelected = indexPath
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func onClose(_ sender: Any) {
        quoteCurrency = data.currencies[prevSelected.row].last
        if quoteCurrency != preQuote {
            page_number = 1
            coinNames = []
            coinIds = [:]
            coinList = [:]
            coinLabels = [:]
        }
        
        self.dismiss(animated: true,completion: nil)
    }

}
