//
//  SubscriptionDetailsViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 4/5/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import SafariServices



class SubscriptionDetailsViewController: UIViewController {

    @IBOutlet var titleL: UILabel!
    @IBOutlet var descL: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var restorePurchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: NSNotification.Name(rawValue: GluuConstants.NOTIFICATION_AD_NOT_FREE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: NSNotification.Name(rawValue: GluuConstants.NOTIFICATION_AD_FREE), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonsContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonsContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        buttonsContainerView.layer.shadowRadius = 6.0
        buttonsContainerView.layer.shadowOpacity = 0.4
        buttonsContainerView.layer.masksToBounds = false
        
    }

    func setupDisplay() {
        title = "Subscription Details"
        
        titleL.text = "Details:"
        
        descL.text = "The monthly subscription makes Super Gluu totally ad-free. After successfully purchasing you will never see banners ads or full screen ads.\n\nYour payment will be charged to your iTunes Account once you confirm your purchase.\n\nYour iTunes account will be charged again when your subscription automatically renews at the end of your current subscription period unless auto-renew is turned off at least 24 hours prior to end of the current period.\n\nAny unused portion of the free trial period will be forfeited when subscription is purchased. You can manage or turn off auto-renew in your Apple ID Account Settings any time after purchase."
        
        purchaseButton.backgroundColor = Constant.appGreenColor()
        purchaseButton.layer.cornerRadius = purchaseButton.bounds.height / 2
        
        restorePurchaseButton.setTitleColor(Constant.appGreenColor(), for: .normal)
        
        
    }
    
    @IBAction func privacyTapped() {
        showSafariForURL(URL: NSURL(string: "https://docs.google.com/document/d/1E1xWq28_f-tam7PihkTZXhlqaXVGZxJbVt4cfx15kB4/edit#heading=h.ifitnnlwr25")!)
    }
    
    @IBAction func tosTapped() {
        showSafariForURL(URL: NSURL(string: "https://gluu.org/docs/supergluu/user-guide/")!)
    }
    
    @IBAction func restorePurchaseTapped() {
        restorePurchaseButton.showSpinner()
        ADSubsriber.sharedInstance().restorePurchase()
    }
    
    @IBAction func purchaseTapped() {
        purchaseButton.showSpinner()
        ADSubsriber.sharedInstance().tryToSubsribe()
    }
    
    
    func showSafariForURL(URL: NSURL) {
        let viewController = SFSafariViewController(url: URL as URL)
        present(viewController, animated: true, completion: nil)
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    
//    -(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }
    


}
