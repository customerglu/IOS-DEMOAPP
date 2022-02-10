//
//  File.swift
//  
//
//  Created by kapil on 03/11/21.
//

import Foundation
import UIKit

public class OpenWalletViewController: UIViewController {
       
    var my_url = ""
    var anotherOptionalInt: Int?
    
    // MARK: - Variables
    private var openWalletViewModel = OpenWalletViewModel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .white

        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if UserDefaults.standard.object(forKey: Constants.WalletRewardData) != nil {
            let userDefaults = UserDefaults.standard
            do {
                let campaignsModel = try userDefaults.getObject(forKey: Constants.WalletRewardData, castTo: CampaignsModel.self)
                self.my_url = campaignsModel.defaultUrl
                DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                    self.presentWebViewController(url: self.my_url)
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            if ApplicationManager.doValidateToken() == true {
                callOpenWalletApi()
            } else {
                openWalletViewModel.updateProfile { success, _ in
                    if success {
                        self.callOpenWalletApi()
                    } else {
                        print("error")
                    }
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
                    self.presentWebViewController(url: self.my_url)
                }
            } else {
                CustomerGlu.getInstance.loaderHide()
                print("error")
            }
        }
    }
    
    private func presentWebViewController(url: String) {
        let customerWebViewVC = CustomerWebViewController()
        customerWebViewVC.urlStr = url
        customerWebViewVC.openWallet = true
        customerWebViewVC.delegate = self
        customerWebViewVC.modalPresentationStyle = .overCurrentContext
        self.present(customerWebViewVC, animated: false)
    }
}

extension OpenWalletViewController: CustomerGluWebViewDelegate {
    func closeClicked(_ success: Bool) {
        dismiss(animated: false, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
