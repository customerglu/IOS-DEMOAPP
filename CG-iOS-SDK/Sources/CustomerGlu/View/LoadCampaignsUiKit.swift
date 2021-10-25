//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 16/08/21.
//

import Foundation


import SwiftUI

@available(iOS 13.0, *)
 struct LoadCampaignsUiKit: View {
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    @Environment(\.presentationMode) var presentationMode
    

    @State var campaigns:[Campaigns]=[]
    
    public func getCampaign() {
        let mytoken = UserDefaults.standard.string(forKey: "CustomerGlu_Token")

        CustomerGlu().retrieveData(customer_token: mytoken ?? "sdas", completion: { CampaignsModel in
            campaigns = CampaignsModel.campaigns!
       })
    }
    
    public var body: some View
    {
        NavigationView
        {
         VStack
         {
            HStack
            {
                Image(systemName: "chevron.left")
                    .frame(width: 30, height: 30, alignment: .center)
                    .onTapGesture {
                       // UIApplication.keyWin?.rootViewController?.dismiss(animated: true, completion: nil)
                        guard let topController = UIViewController.topViewController() else {
                                                             return
                                                         }
                        topController.dismiss(animated: true, completion: nil)


                    }
                
                Text("Campaigns")
                    .bold()
                    .font(.system(size: 30))
                    .navigationBarHidden(true)
                Spacer()
            }.padding(.all,10)
           
            List(campaigns,id:\.campaignId)
                  {
                      element in
                      
                ZStack(alignment:.leading)
                {
                    if element.banner != nil
                    {
                    if element.banner?.imageUrl == nil && element.banner?.title == nil
                            {
                        BannerCell(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: "",url:element.url )
                             }
                        
                       else if element.banner?.imageUrl == nil{
                        BannerCell(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: (element.banner?.title)!,url: element.url)
                        }
                        
                        else if element.banner?.title == nil
                        {
                            BannerCell(image_url: (element.banner?.imageUrl!)!, title:"",url: element.url)
                        }
                        else{
                            BannerCell(image_url: (element.banner?.imageUrl!)!, title:(element.banner?.title!)!,url: element.url)
                            
                        }

                    }
                    else
                    {
            BannerCell(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: "",url: element.url)
                        
                  
                     
                    }
                }.buttonStyle(PlainButtonStyle())
            

            }.background(Color.white)
            .listStyle(PlainListStyle())

            
            
            Spacer()

            
                  }.onAppear(perform: {getCampaign()})
         .background(Color.white)
        }
        
            .navigationBarHidden(true)

        .background(Color.white)
      
       
    }
    }





