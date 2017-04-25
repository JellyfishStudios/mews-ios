//
//  TableViewController.swift
//  Mews
//
//  Created by adunne on 7/18/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

class TableViewController: UITableViewController {

    @IBOutlet weak var furiganaToggleSegment: UISegmentedControl!
    
    @IBAction func furiganaSegmentChanged(_ sender: UISegmentedControl) {
        furiganaEnabled = (sender.selectedSegmentIndex == 0)
        
        self.refresh()
    }
    fileprivate var myarticles = Array<Article>()
    
    fileprivate func addAttributesLabelContent(_ attributesLabel: UILabel, article: Article) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy h:m a"
        let dateString = dateFormatter.string(from: article.publicationDate! as Date)
        
        attributesLabel.text = dateString
    }
    
    fileprivate func addTitleView(_ parentView: UIView, article: Article) {
        parentView.subviews.forEach { (view) -> () in
            view.removeFromSuperview()
        }
        
        let rubyView = FuriganaTextView(frame: CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height))
        
        rubyView.furiganaEnabled = furiganaEnabled
        rubyView.furiganaTextStyle.paragraphIndent = false
        rubyView.furiganas = article.title?.furigana
        rubyView.contents = NSMutableAttributedString(string: (article.title?.original)!)
        rubyView.contentView?.backgroundColor = UIColor.clear
        rubyView.contentView?.font = UIFont (name: (rubyView.contentView?.font?.fontName)!, size: 15)
        rubyView.contentView?.isScrollEnabled = false
        
        parentView.addSubview(rubyView)
    }
    
    func refresh()
    {
        loadDataIntoTable()
        
        self.refreshControl?.endRefreshing()
    }
    
    func loadDataIntoTable() {
        ArticleManager.singleton.fetch({ (result) -> Void in
            switch result {
            case .success(let articles):
                DispatchQueue.main.async(execute: {
                    self.myarticles = articles
                    
                    self.tableView.reloadData()
                })
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(TableViewController.refresh), for: UIControlEvents.valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadDataIntoTable()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myarticles.count
    }
    
    fileprivate func populatePrimaryCell(_ indexPath: IndexPath, article: Article) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularPrimaryTableViewCell", for: indexPath) as! PopularPrimaryTableViewCell
        
        cell.layoutIfNeeded()
        
        // Some additional cell configuration
        //
        cell.thumbnailView?.layer.cornerRadius = 8
        
        // Build and add a ruby text view
        //
        addTitleView(cell.titleView, article: article)
        
        // Add any other attribs / meta data such as publication date
        //
        addAttributesLabelContent(cell.attributeLabel, article: article)
        
        if article.imageURL != nil {
            cell.thumbnailView?.sd_setImage(
                with: URL(string: article.imageURL!),
                placeholderImage: UIImage(named: "Mews Bowing 320x200"),
                options: SDWebImageOptions(),
                completed: { (image, error, cacheType, url) -> Void in
                    
                if image == nil {
                    if error != nil {
                        print(error!)
                    }
                    return
                }
                
                let viewWidth = cell.thumbnailView?.bounds.width
                let viewHeight = cell.thumbnailView?.bounds.height
                
                let size = CGSize(width: viewWidth!, height: viewHeight!)
                
                let scale = max(size.width/(image?.size.width)!, size.height/(image?.size.height)!)
                
                let width = (image?.size.width)! * scale
                let height = (image?.size.height)! * scale
                
                let thumbnailRect = CGRect(x: 0, y: 0, width: width, height: height)
                
                UIGraphicsBeginImageContextWithOptions(size, false, 0)
                image?.draw(in: thumbnailRect)
                
                let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                DispatchQueue.main.async(execute: {
                    cell.thumbnailView?.image = thumbnail
                })
            })
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 300
        }
        else {
            if myarticles[(indexPath as NSIndexPath).row].id == AppContext.singleton.adMarker {
                return 100
            }
            
            return 120
        }
    }
    
    fileprivate func populateSecondaryCell(_ indexPath: IndexPath, article: Article) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularSecondaryTableViewCell", for: indexPath) as! PopularSecondaryTableViewCell
        
        cell.layoutIfNeeded()
        
        // Some additional cell configuration
        //
        cell.thumbnailView?.layer.cornerRadius = 8
        
        // Build and add a ruby text view
        //
        addTitleView(cell.titleView, article: article)
        
        // Add any other attribs / meta data such as publication date
        //
        addAttributesLabelContent(cell.attributeLabel, article: article)
        
        if article.imageURL != nil {
            cell.thumbnailView?.sd_setImage(
                with: URL(string: article.imageURL!),
                placeholderImage: UIImage(named: "Mews Bowing 120x120"),
                options: SDWebImageOptions(),
                completed: { (image, error, cacheType, url) -> Void in
                    
                if image == nil {
                    if error != nil {
                        print(error!)
                    }
                    return
                }
                
                let viewWidth = cell.thumbnailView?.bounds.width
                let viewHeight = cell.thumbnailView?.bounds.height
                
                let size = CGSize(width: viewWidth!, height: viewHeight!)
                
                let scale = max(size.width/(image?.size.width)!, size.height/(image?.size.height)!)
                
                let width = (image?.size.width)! * scale
                let height = (image?.size.height)! * scale
                
                let thumbnailRect = CGRect(x: 0, y: 0, width: width, height: height)
                
                UIGraphicsBeginImageContextWithOptions(size, false, 0)
                image?.draw(in: thumbnailRect)
                
                let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                DispatchQueue.main.async(execute: {
                    cell.thumbnailView?.image = thumbnail
                })
            })
        }
        
        return cell
    }
    
    fileprivate func populateAdCell(_ indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdTableViewCell", for: indexPath)
        
        cell.layoutIfNeeded()
        
        let bannerView = cell.contentView.subviews[0] as! GADBannerView
        
        // Load ad placement
        //
        bannerView.adUnitID = AppContext.singleton.listingsadMobAppBannerID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Theese are loaded in viewDidLoad
        //
        let article = myarticles[(indexPath as NSIndexPath).row]
        
        if article.id == "XXX" {
            return populateAdCell(indexPath)
        }
        
        if (indexPath as NSIndexPath).row == 0 {
            return populatePrimaryCell(indexPath, article: article)
        }
       
        return populateSecondaryCell(indexPath, article: article)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "primaryArticleDetailSegueID" ||
            segue.identifier == "secondaryArticleDetailSegueID"{
            let destination = segue.destination as? ViewController
            let articleIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            
            destination?.article = myarticles[articleIndex!]
        }
    }
}
