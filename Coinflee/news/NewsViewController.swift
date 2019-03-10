//
//  NewsViewController.swift
//  Bitcoin
//
//  Created by Alex on 01/02/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SafariServices
import MBProgressHUD

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , XMLParserDelegate {
    var language = LanguageFile()
    var isReloading = false
    
    var myFeed : NSArray = []
    var myTitle : NSArray = []
    var feedImgs: [AnyObject] = []
    var url: URL!
    
    var parser = XMLParser()
    var currentElement:String = ""
    var foundCharacters = ""
    var passData:Bool=false
    var parsedData = [[String:String]]()
    var currentData = [String:String]()
    var isHeader = true
    
    var loadNumber = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Latest: UINavigationItem!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parsedData = [[String:String]]()
        Latest.title = language.localizedString(str: "Latest News")
        self.showHUD()
        self.loadData()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 120
      
        
    }
    
    func showHUD(){
        
        if let parentController = self.parent?.parent as? UITabBarController {
            MBProgressHUD.showAdded(to: (parentController.view)!, animated: true)
        }
    }
    
    @IBAction func goCoinbase(_ sender: Any) {
        let urlString = "https://coinbase-consumer.sjv.io/9nJy3"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
    
    @IBAction func goRobinhood(_ sender: Any) {
        let urlString = "https://referral.robinhood.com/yanniem"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
    @IBAction func goChangelly(_ sender: Any) {
        let urlString = "https://old.changelly.com/?ref_id=qso2bg0jqpzvom2n"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: urlString)!
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
    }
    
    
    func dismissHUD(isAnimated:Bool) {
       
        if let parentController = self.parent?.parent as? UITabBarController {
            MBProgressHUD.hide(for: (parentController.view)!, animated: isAnimated)
        }
    }
    
    func loadData() {
        self.parsedData = []
        loadNumber = 1
//        url = URL(string: "http://news.bitcoin.com/feed")!
//        loadRss(url)
        url = URL(string: "http://cointelegraph.com/rss")!
        loadRss(url)
        url = URL(string: "http://bitcoinist.com/feed/")!
        loadRss(url);
    }
    
    func loadRss(_ data: URL) {
        
        DispatchQueue.global().async {
            self.parser = XMLParser(contentsOf: data)!
            self.parser.delegate = self
            let success:Bool = self.parser.parse()
            
            if success {
                print("parse success!")
                print(self.loadNumber)
                self.loadNumber += 1
                self.parsedData.append(self.currentData)
                
                if self.loadNumber == 2 {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.parsedData.sort(by: {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                            guard let date_0 = dateFormatter.date(from: $0["pubDate"]!),
                                let date_1 = dateFormatter.date(from: $1["pubDate"]!) else {
                                    return false
                            }
                            return date_0.compare(date_1) == .orderedDescending
                        })
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
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
                            self.dismissHUD(isAnimated: true)
                            self.tableView.reloadData()
                        })
                    }
                    
                }
            } else {
                print("parse failure!")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openDetail" {
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            return
        }
        
        var cellData = parsedData[indexPath.row-1]
        
        guard var urlString = cellData["link"]
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        urlString = urlString.replacingOccurrences(of: " ", with: "")
        urlString = urlString.replacingOccurrences(of: "\n", with: "")
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        guard let url = URL(string: urlString) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(red: 3.0/255,green: 73.0/255,blue: 184.0/255,alpha: 1.0)
        vc.preferredControlTintColor = UIColor.white
        vc.delegate = self as? SFSafariViewControllerDelegate
        self.present(vc, animated: true,completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset < 0 && isReloading == false {
            isReloading = true
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
            self.tableView.tableHeaderView = spinner;
            self.loadData()
        }
    }
    
    
    func safariViewControllerFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return parsedData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! NewsTableHeaderCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        
        
        cell.tempNewsImage.layer.cornerRadius = 42
        cell.tempNewsImage.layer.masksToBounds = true
        
        if parsedData.count == 0 {
            return cell
        }
        var cellData = parsedData[indexPath.row-1]

        var image: UIImage? = nil
        
        DispatchQueue.global().async{
            if let media = cellData["media:content"],
                let url = URL(string: media),
                let data = NSData(contentsOf:url as URL){
                do {
                    
                    image = UIImage(data:data as Data)
                }
            }
            DispatchQueue.main.async(execute: {
                if let img = image {
                    image = self.resizeImage(image: img, toTheSize: CGSize(width: 100, height: 100))
                    cell.tempNewsImage.image = image
                }
            })
        }
        
        if (cellData["header_title"]?.lowercased().contains("cointelegraph"))! {
            cell.firstLabel.text = "Cointelegraph"
        } else if (cellData["header_title"]?.lowercased().contains("bitcoinist"))! {
            cell.firstLabel.text = "Bitcoinist"
        } else {
            cell.firstLabel.text = cellData["header_title"]
        }
        
        cell.secondLabel.text = cellData["title"]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date = dateFormatter.date(from: cellData["pubDate"]!)
        cell.dateLabel.text = relativePast(for: date!)
        
        return cell
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    
    func setupTitleView() {
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 3.0/255,green: 99.0/255,blue: 184.0/255,alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        let f = DateFormatter()
        let weekDay = f.shortWeekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
        let day = Calendar.current.component(.day, from: Date())
        
        let topText = NSLocalizedString(weekDay.uppercased(), comment: "")
        let bottomText = NSLocalizedString(String(day), comment: "")
        
        let titleParameters = [NSAttributedString.Key.foregroundColor : UIColor.black,
                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: 9.0)]
        let subtitleParameters = [NSAttributedString.Key.foregroundColor : UIColor.black,
                                  NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)]
        
        let title:NSMutableAttributedString = NSMutableAttributedString(string: topText, attributes: titleParameters)
        let subtitle:NSAttributedString = NSAttributedString(string: bottomText, attributes: subtitleParameters)
        
        title.append(NSAttributedString(string: "\n"))
        title.append(subtitle)
        
        //let size = title.size()
        
        //let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {return}
        
        let titleLabel = UILabel(frame: CGRect(x: 0,y: 0, width: height - 8, height: height - 8))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        titleLabel.backgroundColor = UIColor.white
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 5
        
        let leftBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)]
        
    }
    
    func relativePast(for date : Date) -> String {
        
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())
        
        if components.year! > 0 {
            return "\(components.year!) " + (components.year! > 1 ? "years ago" : "year ago")
            
        } else if components.month! > 0 {
            return "\(components.month!) " + (components.month! > 1 ? "months ago" : "month ago")
            
        } else if components.weekOfYear! > 0 {
            return "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks ago" : "week ago")
            
        } else if (components.day! > 0) {
            return (components.day! > 1 ? "\(components.day!) days ago" : "Yesterday")
            
        } else if components.hour! > 0 {
            return "\(components.hour!) " + (components.hour! > 1 ? "hours ago" : "hour ago")
            
        } else if components.minute! > 0 {
            return "\(components.minute!) " + (components.minute! > 1 ? "minutes ago" : "minute ago")
            
        } else {
            return "\(components.second!) " + (components.second! > 1 ? "seconds ago" : "second ago")
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName;
        
        if currentElement == "item" || currentElement == "entry" {
            if isHeader == false {
                parsedData.append(currentData)
            }
            isHeader = false
        }
        if currentElement == "channel" {
            isHeader = true
        }
        
        if isHeader == false {

            if currentElement == "media:content" || currentElement=="media:thumbnail" {
                if let url = attributeDict["url"] {
                     foundCharacters += url
                }
            }
        }
       
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !foundCharacters.isEmpty {
            foundCharacters = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            currentData[currentElement] = foundCharacters
            foundCharacters = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
       
        if isHeader == false {
            
            if currentElement == "title" || currentElement == "link" || currentElement == "pubDate"
//                || currentElement == "description" || currentElement == "content" || currentElement == "author" || currentElement == "dc:creator" || currentElement == "content:encoded"
            {
                foundCharacters += string
                foundCharacters = foundCharacters.deleteHTMLTags(tags: ["a", "p", "div", "img"])
            }
        }
        
        if isHeader == true {
            if currentElement == "title" {
                currentElement = "header_title"
                foundCharacters += string
                foundCharacters = foundCharacters.deleteHTMLTags(tags: ["a", "p", "div", "img"])
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }

}

extension String {
    func deleteHTMLTag(tag:String) -> String {
        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
    }
    
    func deleteHTMLTags(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag: tag)
        }
        return mutableString
    }
}
