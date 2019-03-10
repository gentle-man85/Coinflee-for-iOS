//
//  UpgradeProViewController.swift
//  Bitcoin
//
//  Created by Alex on 01/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import WebKit

var proversionType: Int?

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0) { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.25 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.7 { didSet { updateLocations() }}
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

class UpgradeProViewController: UIViewController, WKScriptMessageHandler {
    var language = LanguageFile()
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var Upgrage: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var UpgradeButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        Upgrage.text = language.localizedString(str: "Upgrade to Pro")
//        message.text = language.localizedString(str: "UpgradeMessage")
//        UpgradeButton.setTitle(language.localizedString(str: "Upgrade"), for: .normal)
    }
   
    @IBOutlet weak var webViewContentView: UIView!
    @IBOutlet weak var bottomView: UIView!
    var webView: WKWebView!
    var fullWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backView.addSubview(GradientView(frame: self.view.frame))
        
        let contentController = WKUserContentController()       
        contentController.add(self, name: "linkAction")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.bottomView.bounds, configuration: config)
        self.bottomView.addSubview(self.webView)
        
        
        let htmlPath = Bundle.main.path(forResource: "donate", ofType: "html")
        let url = URL(fileURLWithPath: htmlPath!)
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "linkAction" {
            print("Javascript is sending a message \(message.body)")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                
                self.fullWebView = WKWebView(frame: self.webViewContentView.bounds)
                self.webViewContentView.addSubview(self.fullWebView)
                
                let requestUrl = URL(string: "https://commerce.coinbase.com/checkout/b374cdab-a5cc-4732-8079-faa0d1f72618")!
                let request = URLRequest(url: requestUrl)
                self.fullWebView.load(request)
            })
        }
    }
    
    
    @IBAction func onCloseButton(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
}
