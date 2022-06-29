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
    public var auto_close_webview = CustomerGlu.auto_close_webview
    
    var my_url = ""
    var anotherOptionalInt: Int?
    
    // MARK: - Variables
    private var openWalletViewModel = OpenWalletViewModel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if ApplicationManager.doValidateToken() == true {
            callOpenWalletApi()
        } else {
            openWalletViewModel.updateProfile { success in
                if success {
                    self.callOpenWalletApi()
                } else {
                    print("error")
                }
            }
        }
    }
    
    private func callOpenWalletApi() {
        CustomerGlu.getInstance.loaderShow(withcoordinate: self.view.frame.midX - 30, y: self.view.frame.midY - 30)
        ApplicationManager.openWalletApi { success, campaignsModel in
            if success {
                CustomerGlu.getInstance.loaderHide()
                self.my_url = campaignsModel!.defaultUrl
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = self.my_url
                    customerWebViewVC.auto_close_webview = self.auto_close_webview
                    customerWebViewVC.openWallet = true
                    customerWebViewVC.delegate = self
                    customerWebViewVC.modalPresentationStyle = .overCurrentContext
                    self.present(customerWebViewVC, animated: true) {
                        CustomerGlu.getInstance.hideFloatingButtons()
                    }
                }
            } else {
                CustomerGlu.getInstance.loaderHide()
                print("error")
            }
        }
    }
}

extension OpenWalletViewController: CustomerGluWebViewDelegate {
    func closeClicked(_ success: Bool) {
        dismiss(animated: false, completion: {
            self.dismiss(animated: true, completion: nil)
            CustomerGlu.getInstance.showFloatingButtons()
        })
    }
}
