//
//  HomeScreen.swift
//  CustomerGluDemoApp
//
//  Created by Himanshu Trehan on 20/07/21.
//
import SwiftUI
import CustomerGlu
import Firebase

@available(iOS 13.0, *)

struct HomeScreen: View {
    @State var active = false
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    var customerglu = CustomerGlu()
    
    @State var token = ""
    @State var fcmRegTokenMessage = ""
    
    func initializeGlu() {
        
        fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"
        print("my fcm")
        print(fcmRegTokenMessage)
        //   let mykey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMER_WRITE_KEY")
        //  print(mykey)
        let parameters = [
            "userId": "testuser2018",
            "deviceId": "deviceb",
            // "writeKey": "G4VCVVAcLub8hx5SaeqH3pRqLBmDFrwy",
            "firebaseToken": fcmRegTokenMessage]
        
        customerglu.doRegister(body: parameters) { registrationModel, success  in
//            token = (registrationModel.data?.token)!
//            print("dssd")
//            //   print(token)
//            print(UserDefaults.standard.string(forKey: "CustomerGlu_Token") as Any)
        }
    }
    
    func getFcmToken() {
        
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
        NavigationView {
            VStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    HStack {
                    }
                    Image("customerglu")
                }.frame(width: width, height: (height/4))
                    .foregroundColor(.black)
                    .navigationTitle("Home")
                    .navigationBarHidden(true)
                HStack {
                    NavigationLink(
                        destination: OpenWallet(),
                        label: {
                            productCard(image: "purse", title: "Wallet")
                        })
                    Spacer()
                    NavigationLink(
                        destination: LoadAllCampaigns(customer_token: token),
                        label: {
                            productCard(image: "coin", title: "Rewards")
                        })
                }.padding(.horizontal, 10)
                HStack {
                    NavigationLink(
                        destination: ShopScreen(),
                        label: {
                            productCard(image: "shop", title: "Shop")
                            
                        })
                    Spacer()
                    NavigationLink(
                        destination: CartScreen(),
                        isActive: $active,
                        label: {
                            productCard(image: "trolley", title: "Cart")
                        })
                }.padding(.horizontal, 10)
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
