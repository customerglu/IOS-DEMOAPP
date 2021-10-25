//
//  SwiftUIView.swift
//  
//
//  Created by Himanshu Trehan on 24/07/21.
//

import SwiftUI
import UIKit
@available(iOS 13.0, *)

public struct OpenWallet: View {
    
    @State var fromUikit = false
    @State var my_url=""

    public init(fromKit:Bool = false){
        fromUikit = fromKit
    }
  
   public var body: some View {
        VStack
        {
            if my_url=="" 
            {
                EmptyView()
            }
            else
            {
                CustomerWebView(my_url: my_url,fromWallet: true,fromUikit: false)
            }
        }
        .onAppear(perform: getCampaigns)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
   }
//    public func closeView()
//    {
//        self.presentationMode.wrappedValue.dismiss()
//    }
    
    
   
    public func getCampaigns()
     {
        let mytoken = UserDefaults.standard.string(forKey: "CustomerGlu_Token")
        CustomerGlu().retrieveData(customer_token: mytoken ?? "sa") { CampaignsModel in
             my_url = CampaignsModel.defaultUrl
            print(my_url)
        }
     }
}
