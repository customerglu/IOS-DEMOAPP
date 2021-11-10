//
//  File.swift
//  
//
//  Created by kapil on 03/11/21.
//

import Foundation
import UIKit
import SwiftUI

public class OpenWalletViewController: UIViewController {
    
    public static let storyboardVC = UIStoryboard(name: "Storyboard", bundle: .module).instantiateViewController(withIdentifier: "OpenWalletViewController")
    
    var my_url = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        getCampaigns()
    }

    private func getCampaigns() {
        CustomerGlu.single_instance.getWalletRewards { success, campaignsModel in
            if success {
                self.my_url = campaignsModel!.defaultUrl
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    let customerWebViewVC = UIStoryboard(name: "Storyboard", bundle: .module).instantiateViewController(withIdentifier: "CustomerWebViewController") as? CustomerWebViewController
                    customerWebViewVC!.urlStr = self.my_url
                    customerWebViewVC!.openWallet = true
                    customerWebViewVC!.delegate = self
                    customerWebViewVC!.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(customerWebViewVC!, animated: false)
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
