//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 16/08/21.
//

import Foundation
import SwiftUI
@available(iOS 13.0, *)

struct OpenUiKitWallet: View {
    
    @State var my_url = ""
    public var body: some View {
        VStack {
            if my_url == "" {
                EmptyView()
            } else {
                CustomerWebView(my_url: my_url, fromWallet: true, fromUikit: true)
            }
        }.onAppear(perform: getCampaigns)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
   
    public func getCampaigns() {
        CustomerGlu.single_instance.getWalletRewards { success, campaignsModel in
            if success {
                my_url = campaignsModel!.defaultUrl
                print(my_url)
            } else {
                print("error")
            }
        }
    }
}
