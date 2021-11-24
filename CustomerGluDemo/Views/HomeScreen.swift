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
    var customerglu = CustomerGlu.single_instance
    
    @State var token = ""
    @State var fcmRegTokenMessage = ""
        
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
                        destination: OpenWalletUIKit(),
//                        destination: OpenWallet(),
                        label: {
                            productCard(image: "purse", title: "Wallet")
                        })
                    Spacer()
                    NavigationLink(
                        destination: RewardUIKit(),
//                        destination: LoadAllCampaigns(customer_token: token),
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
                initializeGlu()
            })
        }.ignoresSafeArea(.all)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
    
    func initializeGlu() {
        fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"
        let parameters = [
            "userId": "hitesh11",
            "deviceId": "deviceb",
            "firebaseToken": fcmRegTokenMessage]
        
        customerglu.doRegister(body: parameters) { success, registrationModel in
            if success {
                token = (registrationModel?.data?.token)!
                print(UserDefaults.standard.string(forKey: "CustomerGlu_Token") as Any)
                customerglu.getWalletRewards { _, _ in
                }
            } else {
                print("error")
            }
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
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
