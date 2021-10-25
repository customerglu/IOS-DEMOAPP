//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 29/08/21.
//

import Foundation


//
//  SwiftUIView.swift
//
//
//  Created by Himanshu Trehan on 24/07/21.
//

import SwiftUI
import UIKit
@available(iOS 13.0, *)

 struct NotificationHandler: View {
    
    @State var fromUikit = false
    @State var my_url:String
    @State var ismiddle = false
  
    var body: some View {
        VStack
        {
            if my_url==""
            {
                EmptyView()
                
            }
            else
            {
                if ismiddle
                {
                 
                                       VStack(alignment: .center, spacing: 0) {
                                        CustomerWebView(my_url: my_url,fromWallet: true,fromUikit: true)

                                       }
                                       .frame(maxWidth: 300,maxHeight: 300)
                                   
                                   }
                    
                
                else
                {
                CustomerWebView(my_url: my_url,fromWallet: true,fromUikit: true)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
   }

    

}
