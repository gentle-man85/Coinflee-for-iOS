//
//  NewsDetailViewController.swift
//  Bitcoin
//
//  Created by Alex on 01/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class NewsDetailViewController: UIViewController{

    var selectedFeedURL: String?
    var textView : UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var isReadMode: UIBarButtonItem!
    @IBOutlet var myWebView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedFeedURL =  selectedFeedURL?.replacingOccurrences(of: " ", with:"")
        selectedFeedURL =  selectedFeedURL?.replacingOccurrences(of: "\n", with:"")

        //myWebView.load(URLRequest(url: URL(string: selectedFeedURL! as String)!))
        //self.myWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        self.title = "Cointelegraph.com"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)]
        self.navigationItem.hidesBackButton = true
//        textView = UILabel()
//        textView.text = "Cointelegraph.com"
//        textView.textColor=UIColor.white
//        navigationItem.titleView = textView
        
        
        
        
        
        
        
        
    }
    func safariViewControllerFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onDone(_ sender: Any) {
        
//        let urlString = "http://cryptocompare.com"
//        let config = SFSafariViewController.Configuration()
//        config.entersReaderIfAvailable = true
//        let url = URL(string: urlString)!
//        let vc = SFSafariViewController(url: url, configuration: config)
//        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
//        vc.preferredControlTintColor = UIColor.white
//        vc.delegate = self as? SFSafariViewControllerDelegate
//        self.present(vc, animated: true,completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // Observe value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(self.myWebView.estimatedProgress);
            if self.progressView.progress == 1.0 {
                self.progressView.isHidden = true
            }
        }
    }
    
    
}
