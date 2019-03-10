//
//  AddCoinsViewController.swift
//  Bitcoin
//
//  Created by Alex on 31/01/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.barTintColor = UIColor(red: 240/255,green: 241/255,blue: 243/255,alpha: 1.0)//#F0F1F3
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
    
}

class AddCoinsViewController: UIViewController, UITextFieldDelegate {

    var language = LanguageFile()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var AddTradeButton: UIButton!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var currentpriceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var Amount1: UILabel!
    @IBOutlet weak var Price1: UILabel!
    @IBOutlet weak var CurrentPrice1: UILabel!
    
    
    @IBOutlet weak var coinType: UIView!
    @IBOutlet weak var amountImg: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var currentCoinImage: UIImageView!
    @IBOutlet weak var currentCoinName: UILabel!
    @IBOutlet weak var currentCoinDetailName: UILabel!
    @IBOutlet weak var currentCoinPrice: UILabel!
    @IBOutlet weak var currentCoinRate: UILabel!
    
    var getCoin: String!
    var getTradeType: String!
    var calcPrice: Double = 0.0
    var coinAmount: Double = 0.0
    var curPrice: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Amount1.text = language.localizedString(str: "Amount")
        Price1.text = language.localizedString(str: "Price")
        CurrentPrice1.text = language.localizedString(str: "Current Price")
        AddTradeButton.setTitle(language.localizedString(str: "Add Trade"), for: .normal)
       
        
        amount.delegate = self
        amount.keyboardType = .decimalPad
        amount.textAlignment = .center
        amount.addTarget(self, action: #selector(amountFiledDidChange(_:)), for: .editingChanged)
        amount.addDoneCancelToolbar()
        
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickAmountView))
        coinType.addGestureRecognizer(tapGesture)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.startCoin))
        self.currentpriceView.addGestureRecognizer(gesture)
       
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        let coinName: String
        if let coin = selectedCoin {
            coinName = coin
        } else {
            coinName = "btc"
        }
        
        amountLabel.text = coinName.uppercased()
        amountImg.image = imageList[coinName]
        
        currentCoinImage.image = imageList[coinName]
        currentCoinName.text = coinName.uppercased()
        currentCoinDetailName.text = coinLabels[coinName]
        if let coinDetail = coinList[coinName] {
            let formatter = NumberFormatter()
            formatter.currencyCode = quoteCurrency
            formatter.numberStyle = .currency
            
            let price = JSON(coinDetail)["current_price"].rawString()!
            if Double(price)! > 1 {
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
            } else {
                formatter.minimumFractionDigits = 6
                formatter.maximumFractionDigits = 6
            }
            currentCoinPrice.text = formatter.string(from: NSNumber(value: Double(price)!))
            
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.numberStyle = .percent
            let _availiable = JSON(coinDetail)["price_change_percentage_24h"].rawString()!
            currentCoinRate.text = formatter.string(from: NSNumber(value: Double(_availiable)!/100))
            
            if let raV = Double(_availiable),
                raV > 0.0 {
                currentCoinPrice.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
                currentCoinRate.textColor = UIColor(red: 33.0/255,green: 206.0/255,blue: 153.0/255,alpha: 1.0)
            } else {
                currentCoinPrice.textColor = .red
                currentCoinRate.textColor = .red
            }
            amountFiledDidChange(amount)
            view.setNeedsDisplay()
        }
        amount.text = ""
        priceLabel.text = ""
        if getTradeType == "remove" {
            onAdd(self)
        }
        DispatchQueue.main.async {
            self.amount.becomeFirstResponder()
        }
        
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        
        let components = string.components(separatedBy: inverseSet)
        
        let filtered = components.joined(separator: "")
        
        if filtered == string {
            return true
        } else {
            if string == "." {
                let countdots = textField.text!.components(separatedBy:".").count - 1
                if countdots == 0 {
                    return true
                }else{
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            }else{
                return false
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        scrollview.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amount.resignFirstResponder()
        return true
    }
    
    @objc func amountFiledDidChange(_ textField: UITextField) {
        if let amountText = textField.text,
           let curPriceText = currentCoinPrice.text,
            curPriceText != "---",
             amountText != "",
            amountText != "."
        {
           
            let formatter = NumberFormatter()
            formatter.currencyCode = quoteCurrency
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            if let coinDetail = coinList[selectedCoin],
                let price = Double(JSON(coinDetail)["current_price"].rawString()!)
            {
                curPrice = price
                coinAmount = Double( amountText)!
                
                let amountPrice = coinAmount * curPrice
                calcPrice = amountPrice
                
                if AddButton.titleLabel!.text == "+" {
                    priceLabel.text = "+" + formatter.string(from: NSNumber(value: amountPrice))!
                } else if AddButton.titleLabel!.text == "-" {
                    priceLabel.text = "-" + formatter.string(from: NSNumber(value: amountPrice))!
                }
            }
        } else {
            priceLabel.text = ""
        }
        
    }
    
    @objc func startCoin(sender : UITapGestureRecognizer) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "bitcoinDetail") as! DetailViewController
        newViewController.getCoin = selectedCoin
        self.navigationController?.show(newViewController, sender: true)
    }
    
    
    @objc func clickAmountView(sender : UITapGestureRecognizer) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "selectCoin") as! SelectCoinDetailViewController
        self.navigationController?.show(newViewController, sender: true)
    }
    

    @IBAction func onAdd(_ sender: Any) {
        if AddButton.backgroundColor == UIColor(red: 222.0/255,green: 71.0/255, blue: 47.0/255,alpha: 1.0)
        {
            AddButton.backgroundColor = UIColor(red: 33.0/255,green: 206.0/255, blue: 153.0/255,alpha: 1.0)
            AddTradeButton.backgroundColor = UIColor(red: 33.0/255,green: 206.0/255, blue: 153.0/255,alpha: 1.0)
            
            AddButton.setTitle("+", for: .normal)
            AddTradeButton.setTitle("Add Trade",for:.normal)
            imageView.image = UIImage(named: "rocket")
            priceLabel.text = priceLabel.text?.replacingOccurrences(of: "-", with: "+")
           
       }
        else
        {
            AddButton.backgroundColor = UIColor(red: 222.0/255,green: 71.0/255, blue: 47.0/255,alpha: 1.0)
            AddTradeButton.backgroundColor = UIColor(red: 222.0/255,green: 71.0/255, blue: 47.0/255,alpha: 1.0)
            AddButton.setTitle("-", for: .normal)
            AddTradeButton.setTitle("Remove Trade", for: .normal)
            imageView.image = UIImage(named: "rocketSub")
            priceLabel.text = priceLabel.text?.replacingOccurrences(of: "+", with: "-")
           
        }
    }
    
    @IBAction func onAddTrade(_ sender: Any) {
        
        
        if coinAmount != 0,
            amount.text != "" {
           
            if AddButton.titleLabel!.text == "-"
            {
                coinAmount = -coinAmount
            }
            
            let timeInterval = Date().timeIntervalSince1970
            
            if tradeCoinNames.firstIndex(of: selectedCoin) != nil {
                if tradeCoins[selectedCoin] == nil {
                    tradeCoins[selectedCoin] = [["amount": coinAmount, "price": curPrice, "time": timeInterval]]
                } else {
                    tradeCoins[selectedCoin]!.append(["amount": coinAmount, "price": curPrice, "time": timeInterval])
                }
            } else {
                tradeCoins[selectedCoin] = [["amount": coinAmount, "price": curPrice, "time": timeInterval]]
                tradeCoinNames.append(selectedCoin)
                tradeCoinIds[selectedCoin] = coinIds[selectedCoin]
                
                UserDefaults.standard.set(tradeCoinNames, forKey: "tradeCoinNames")
                UserDefaults.standard.set(tradeCoinIds, forKey: "tradeCoinIds")
            }            
            
            UserDefaults.standard.set(tradeCoins, forKey: "tradeCoins")
        
            self.tabBarController?.selectedIndex = 1
        }
        
    }
}
