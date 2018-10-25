//
//  ViewController.swift
//  Mews
//
//  Created by adunne on 7/13/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var scrollViewParentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var loadingView: UIView?
    var activityIndicator: UIActivityIndicatorView?
    
    var rubyView: FuriganaTextView?
    var article: Article?
    var imDisappearing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        loadingView!.backgroundColor = UIColor.white
        self.view.addSubview(loadingView!)
        
        let loadingImage = UIImage(named: "Mews Bowing 120x120")
        let loadingImageView = UIImageView(image: loadingImage)
        loadingImageView.center = loadingView!.center
        
        loadingView!.addSubview(loadingImageView)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator!.style = UIActivityIndicatorView.Style.gray
        activityIndicator!.center = loadingView!.center
        activityIndicator!.frame.origin.y -= ((loadingImageView.frame.size.height / 2) + 20)
        
        loadingView!.addSubview(activityIndicator!)
        
        activityIndicator!.startAnimating()
        activityIndicator!.backgroundColor = UIColor.clear
        
        
        guard article != nil else {
            return
        }
        
        // Remove the image view if there is nothing to show
        //
        if article!.imageURL!.isEmpty {
            articleImageView.removeFromSuperview()
        }
        else {
            articleImageView.sd_setImage(with: URL(string: article!.imageURL!), placeholderImage: UIImage(named: "Mews Bowing 320x200"))
        }
        
        // Load ad placement
        //
        bannerView.backgroundColor = UIColor.black
        bannerView.adUnitID = AppContext.singleton.detailAdMobAppBannerID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imDisappearing = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Before we start writing frames to new views, we should clear any old views
        //
        clearScrollView()
        
        guard imDisappearing == false && article != nil else {
            return
        }
        
        //  Load the main text for the article (will pull from cache if already loaded)
        //
        ArticleManager.singleton.populateArticleDetail(article!.id) { (result) -> Void in
            switch result {
            case .success( _):
                guard let articleMainText = self.article!.main else {
                    print("No article details ...")
                    return
                }
                
                // Will re-draw all the CTFrames/sub-views based on the new parent dimensions
                //
                // CAUTION: This may be called multiple times
                //
                self.addRubyTextView(articleMainText)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator!.stopAnimating()
        activityIndicator!.hidesWhenStopped = true
        
        loadingView?.removeFromSuperview()
    }
    
    fileprivate func clearScrollView() {
        scrollView.subviews.forEach { (view) -> () in
            guard view is FuriganaTextView else {
                return
            }
            
            view.removeFromSuperview()
        }
    }
    
    fileprivate func addRubyTextView(_ contents: FuriganaText){
        rubyView = FuriganaTextView(frame: CGRect(x: 0, y: 0, width: self.scrollViewParentView.bounds.size.width, height: self.scrollViewParentView.bounds.size.height))
        
        rubyView!.furiganaEnabled = furiganaEnabled
        rubyView!.furiganas = contents.furigana
        rubyView!.contents = NSMutableAttributedString(string: contents.original)
        rubyView!.contentView?.backgroundColor = UIColor.clear
        rubyView!.contentView?.font = UIFont (name: (rubyView!.contentView?.font?.fontName)!, size: 15)
        rubyView!.contentView?.showsVerticalScrollIndicator = false
       
        // Complete view width in points. We are side scrolling so height is the same
        //
        self.scrollView.contentSize = CGSize(width: rubyView!.bounds.size.width, height: rubyView!.bounds.size.height)
 
        self.scrollView.addSubview(rubyView!)
    }

}

