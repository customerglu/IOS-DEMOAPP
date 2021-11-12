//
//  File.swift
//  
//
//  Created by kapil on 03/11/21.
//

import Foundation
import UIKit

public class OpenWalletViewController: UIViewController {
    
    public static let storyboardVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
    
    var my_url = ""
    
    // MARK: - Variables
    private var openWalletViewModel = OpenWalletViewModel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        getCampaigns()
    }

    private func getCampaigns() {
        openWalletViewModel.getWalletRewards { success, campaignsModel in
            if success {
                self.my_url = campaignsModel!.defaultUrl
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = self.my_url
                    customerWebViewVC.openWallet = true
                    customerWebViewVC.delegate = self
                    customerWebViewVC.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(customerWebViewVC, animated: false)
                }
            } else {
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "getCampaigns", exception: "error")
            }
        }
    }
}

extension OpenWalletViewController: CustomerGluWebViewDelegate {
    func closeClicked(_ success: Bool) {
        dismiss(animated: false, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}
