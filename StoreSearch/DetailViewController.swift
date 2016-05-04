//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Jun YAO on 16/4/22.
//  Copyright © 2016年 Jun YAO. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var downloadTask: NSURLSessionDownloadTask?
    var searchResult: SearchResult!
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    @IBAction func openInStore(){
        if let url = NSURL(string: searchResult.storeURL){
            UIApplication.sharedApplication().openURL(url)
        }
}
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    deinit{
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        //点击popup外的地方也可以关闭pop up弹窗
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil{
            updateUI()
        }
        
        view.backgroundColor = UIColor.clearColor()
    }
    
    
    func updateUI(){
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = "Unknown"
        }else{
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.kindForDisplay()
    
        genreLabel.text = searchResult.genre
        
        
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        let priceText:String
        if searchResult.price == 0 {
            priceText = "Free"
        }else if let text = formatter.stringFromNumber(searchResult.price){
            priceText = text
        }else{
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
        
        
        
        if let url = NSURL(string: searchResult.artworkURL100){
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
   
    
    

    
}


extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideOutAnimationController()
    }
}

//extension 结合viewDidLoad 点击popup外的地方也可以关闭pop up弹窗
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}