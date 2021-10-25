//
//  SwiftUIView.swift
//  
//
//  Created by Himanshu Trehan on 26/07/21.
//

import SwiftUI

@available(iOS 13.0, *)
public struct LoadAllCampaigns: View {
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    @Environment(\.presentationMode) var presentationMode
    var customer_token:String
    
    public init(customer_token:String)
    {
        self.customer_token = customer_token
    }
    @State var campaigns:[Campaigns]=[]
    
    public func getCampaign() {
        CustomerGlu().retrieveData(customer_token: customer_token, completion: { CampaignsModel in
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
                        presentationMode.wrappedValue.dismiss()
                    
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




