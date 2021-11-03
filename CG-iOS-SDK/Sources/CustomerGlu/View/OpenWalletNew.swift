//
//  File.swift
//  
//
//  Created by kapil on 02/11/21.
//

import Foundation
import UIKit

public class OpenWalletNew: UIView {
    var my_url = ""

    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        getCampaigns()
    }
    
    private func setupView() {
        self.backgroundColor = .red
    }

    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func getCampaigns() {
        CustomerGlu.single_instance.getWalletRewards { success, campaignsModel in
            if success {
                self.my_url = campaignsModel!.defaultUrl
                print(self.my_url)
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.addSubview(CustomerWebViewNew(url: self.my_url))  
                }
            } else {
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "getCampaigns", exception: "error")
            }
        }
    }
}
