//
//  SettingViewController.swift
//  Bitcoin
//
//  Created by Alex on 01/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SafariServices

class SettingViewController: UIViewController {

    var language = LanguageFile()
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var languageView: UIView!
    
    @IBOutlet weak var Settings: UINavigationItem!
    @IBOutlet weak var Manage: UILabel!
    @IBOutlet weak var ProVersion: UIButton!
    @IBOutlet weak var Notification: UILabel!
    @IBOutlet weak var Language1: UILabel!
    @IBOutlet weak var English1: UILabel!
    @IBOutlet weak var Follow: UIButton!
    @IBOutlet weak var Rate: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Settings.title = language.localizedString(str: "Settings")
        Manage.text = language.localizedString(str: "Manage")
        ProVersion.setTitle(language.localizedString(str: "Donating Today?"), for: .normal)
        Notification.text = language.localizedString(str: "Notification")
        Language1.text = language.localizedString(str: "Language")
        Follow.setTitle(language.localizedString(str: "Follow us on twitter"), for: .normal)
        Rate.setTitle(language.localizedString(str: "Rate our app"), for: .normal)
        
        let lang = UserDefaults.standard.string(forKey: "Language")
        switch  lang {
        case "en":
            English1.text = language.localizedString(str: "English")
            break
        case "zh-Hans":
            English1.text = language.localizedString(str: "Chinese")
            break
        case "ja":
            English1.text = language.localizedString(str: "Japanese")
            break
        case "fr":
            English1.text = language.localizedString(str: "French")
            break
        case "tr":
            English1.text = language.localizedString(str: "Turkisy")
            break
        case "ko":
            English1.text = language.localizedString(str: "Korean")
            break
        case "ru":
            English1.text = language.localizedString(str: "Russian")
            break
        case "es":
            English1.text = language.localizedString(str: "Spanish")
            break
        case "pt-PT":
            English1.text = language.localizedString(str: "Portuguese")
            break
        case "de":
            English1.text = language.localizedString(str: "German")
            break
            
        default:
            English1.text = language.localizedString(str: "English")
        }
        
//        if totalPortfolioValue < 1000 && proversionType == 0 {
//            ProVersion.isEnabled = false
//            ProVersion.setTitle(language.localizedString(str: "Donating Today?"), for: .normal)
//        } else {
//            ProVersion.isEnabled = true
//        }
//
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        // button clear
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.checkNotification))
        self.notificationView.addGestureRecognizer(gesture)
        
        let gestureLang = UITapGestureRecognizer(target: self, action: #selector(self.checkLanguage))
        self.languageView.addGestureRecognizer(gestureLang)
    }
    
    @objc func checkNotification(sender: UITapGestureRecognizer)
    {
        mySwitch.setOn(!mySwitch.isOn, animated: true)
    }
    
    @objc func checkLanguage(sender: UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "languageViewController") as! LanguageViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func followAction(_ sender: Any) {
        let urlString = "https://twitter.com/coinflee"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
    
    
    @IBAction func rateAction(_ sender: Any) {
        let urlString = "https://itunes.apple.com/us/app/coinflee-mobile/id1453773634?mt=8&ign-mpt=uo%3D2"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
}
