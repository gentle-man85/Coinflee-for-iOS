//
//  LanguageViewController.swift
//  Bitcoin
//
//  Created by Alex on 01/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {

     var textView : UILabel!
    var language = LanguageFile()
    
    @IBOutlet weak var engCheck: UIImageView!
    @IBOutlet weak var chineseCheck: UIImageView!
    @IBOutlet weak var japCheck: UIImageView!
    @IBOutlet weak var frenchCheck: UIImageView!
    @IBOutlet weak var turCheck: UIImageView!
    @IBOutlet weak var korCheck: UIImageView!
    @IBOutlet weak var rusCheck: UIImageView!
    @IBOutlet weak var spaCheck: UIImageView!
    @IBOutlet weak var porCheck: UIImageView!
    @IBOutlet weak var gerCheck: UIImageView!
    
    @IBOutlet weak var engView: UIView!
    @IBOutlet weak var chiView: UIView!
    @IBOutlet weak var japView: UIView!
    @IBOutlet weak var frenView: UIView!
    @IBOutlet weak var turView: UIView!
    @IBOutlet weak var korView: UIView!
    @IBOutlet weak var rusView: UIView!
    @IBOutlet weak var spaView: UIView!
    @IBOutlet weak var porView: UIView!
    @IBOutlet weak var gerView: UIView!
    
    @IBOutlet weak var English: UILabel!
    @IBOutlet weak var Chinese: UILabel!
    @IBOutlet weak var Japanese: UILabel!
    @IBOutlet weak var French: UILabel!
    @IBOutlet weak var Turkish: UILabel!
    @IBOutlet weak var Korean: UILabel!
    @IBOutlet weak var Russian: UILabel!
    @IBOutlet weak var Spanish: UILabel!
    @IBOutlet weak var Portuguese: UILabel!
    @IBOutlet weak var German: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        English.text = language.localizedString(str: "English")
        Chinese.text = language.localizedString(str: "Chinese")
        Japanese.text = language.localizedString(str: "Japanese")
        French.text = language.localizedString(str: "French")
        Turkish.text = language.localizedString(str: "Turkish")
        Korean.text = language.localizedString(str: "Korean")
        Russian.text = language.localizedString(str: "Russian")
        Spanish.text = language.localizedString(str: "Spanish")
        Portuguese.text = language.localizedString(str: "Portuguese")
        German.text = language.localizedString(str: "German")
        self.tabBarController?.tabBar.isHidden = true
        
        let lang = UserDefaults.standard.string(forKey: "Language")
        switch  lang {
        case "en":
            AllCheckHide()
            engCheck.isHidden = false
            break
        case "zh-Hans":
            AllCheckHide()
            chineseCheck.isHidden = false
            break
        case "ja":
            AllCheckHide()
            japCheck.isHidden = false
            break
        case "fr":
            AllCheckHide()
            frenchCheck.isHidden = false
            break
        case "tr":
            AllCheckHide()
            turCheck.isHidden = false
            break
        case "ko":
            AllCheckHide()
            korCheck.isHidden = false
            break
        case "ru":
            AllCheckHide()
            rusCheck.isHidden = false
            break
        case "es":
            AllCheckHide()
            spaCheck.isHidden = false
            break
        case "pt-PT":
            AllCheckHide()
            porCheck.isHidden = false
            break
        case "de":
            AllCheckHide()
            gerCheck.isHidden = false
            break
            
        default:
            AllCheckHide()
            engCheck.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView = UILabel()
        textView.text = language.localizedString(str: "Language")
        textView.textColor=UIColor.white
        navigationItem.titleView = textView
        
        engCheck.isHidden = false
        
        let gestureE = UITapGestureRecognizer(target: self, action: #selector(self.checkEng))
        self.engView.addGestureRecognizer(gestureE)
        
        let gestureC = UITapGestureRecognizer(target: self, action: #selector(self.checkChi))
        self.chiView.addGestureRecognizer(gestureC)
        
        let gestureJ = UITapGestureRecognizer(target: self, action: #selector(self.checkJap))
        self.japView.addGestureRecognizer(gestureJ)
        
        let gestureF = UITapGestureRecognizer(target: self, action: #selector(self.checkFre))
        self.frenView.addGestureRecognizer(gestureF)
        
        let gestureT = UITapGestureRecognizer(target: self, action: #selector(self.checkTur))
        self.turView.addGestureRecognizer(gestureT)
        
        let gestureK = UITapGestureRecognizer(target: self, action: #selector(self.checkKor))
        self.korView.addGestureRecognizer(gestureK)
        
        let gestureR = UITapGestureRecognizer(target: self, action: #selector(self.checkRus))
        self.rusView.addGestureRecognizer(gestureR)
        
        let gestureS = UITapGestureRecognizer(target: self, action: #selector(self.checkSpa))
        self.spaView.addGestureRecognizer(gestureS)
        
        let gestureP = UITapGestureRecognizer(target: self, action: #selector(self.checkPor))
        self.porView.addGestureRecognizer(gestureP)
        
        let gestureG = UITapGestureRecognizer(target: self, action: #selector(self.checkGer))
        self.gerView.addGestureRecognizer(gestureG)
        
    }
    
    @objc func checkEng(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        engCheck.isHidden = false
        UserDefaults.standard.set("en", forKey: "Language")
    }
    
    @objc func checkChi(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        chineseCheck.isHidden = false
        UserDefaults.standard.set("zh-Hans", forKey: "Language")
        
    }
    
    @objc func checkJap(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        japCheck.isHidden = false
        UserDefaults.standard.set("ja", forKey: "Language")
    }
    
    @objc func checkFre(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        frenchCheck.isHidden = false
        UserDefaults.standard.set("fr", forKey: "Language")
    }
    
    @objc func checkTur(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        turCheck.isHidden = false
        UserDefaults.standard.set("tr", forKey: "Language")
    }
    
    @objc func checkKor(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        korCheck.isHidden = false
        UserDefaults.standard.set("ko", forKey: "Language")
    }
    
    @objc func checkRus(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        rusCheck.isHidden = false
        UserDefaults.standard.set("ru", forKey: "Language")
    }
    
    @objc func checkSpa(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        spaCheck.isHidden = false
        UserDefaults.standard.set("es", forKey: "Language")
    }
    
    @objc func checkPor(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        porCheck.isHidden = false
        UserDefaults.standard.set("pt-PT", forKey: "Language")
    }
    
    @objc func checkGer(sender: UITapGestureRecognizer)
    {
        AllCheckHide()
        gerCheck.isHidden = false
        UserDefaults.standard.set("de", forKey: "Language")
    }
    
    func AllCheckHide()
    {
        engCheck.isHidden = true
        chineseCheck.isHidden = true
        japCheck.isHidden = true
        frenchCheck.isHidden = true
        turCheck.isHidden = true
        korCheck.isHidden = true
        rusCheck.isHidden = true
        spaCheck.isHidden = true
        porCheck.isHidden = true
        gerCheck.isHidden = true
    }
    
}
