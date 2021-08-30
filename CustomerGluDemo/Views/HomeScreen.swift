//
//  HomeScreen.swift
//  CustomerGluDemoApp
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import CustomerGlu
import Firebase
 struct HomeScreen: View {
    @State var active = false
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    var customerglu = CustomerGlu()

    @State var token = ""
    @State var fcmRegTokenMessage = "";
   
    
    func initializeGlu()
    {
        fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"

        print("my fcm")
        print(fcmRegTokenMessage)
        let parameters = [
            "userId": "testuser2010",
            "deviceId": "deviceb",
            "deviceName": "GreyS3",
            "deviceType": "ios",
            "writeKey": "G4VCVVAcLub8hx5SaeqH3pRqLBmDFrwy",
            "firebaseToken": fcmRegTokenMessage
        ]
      
        customerglu.doRegister(body: parameters) { RegistrationModel in
        token = (RegistrationModel.data?.token)!
            print("dssd")
        print(token)
                
            }
    }
    
    func getFcmToken()
    {
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token home: \(token)")
            self.fcmRegTokenMessage  = token
          }
        }
    }
    var body: some View {
        NavigationView
        {
        VStack
        {
          ZStack
          {
            Color.black.ignoresSafeArea()
            HStack{
                
            }
            Image("customerglu")
          }.frame(width: width, height: (height/4))
          .foregroundColor(.black)
          .navigationTitle("Home")
          .navigationBarHidden(true)
            HStack
            {
         
                NavigationLink(
                 destination: OpenWallet(cus_token: token),
                 label: {
                    ProductCard(image: "purse", title: "Wallet")
                     
                 })

                Spacer()
                
                NavigationLink(
                 destination: LoadAllCampaigns(customer_token: token),
                 label: {
                    ProductCard(image: "coin", title: "Rewards")
                     
                 })
                
                
                
            }.padding(.horizontal,10)
            HStack
            {
               NavigationLink(
                destination: ShopScreen(),
                label: {
                    ProductCard(image: "shop", title: "Shop")
                    
                })
                        
                Spacer()
                NavigationLink(
                    destination: CartScreen(),
                    isActive:$active,
                    label: {
                        ProductCard(image: "trolley", title: "Cart")
                        
                    })
               
                
            }.padding(.horizontal,10)
          
            Spacer()
        }.onAppear(perform: {
          //  getFcmToken()
            initializeGlu()
        })
        }.ignoresSafeArea(.all)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        
    }
}
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}


