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
    @State var isAlert = false
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    var customerglu = CustomerGlu.getInstance
            
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    HStack {
                        Spacer()
                        Button(action: {
                            customerglu.clearGluData()
                            UIApplication.shared.keyWindow!.rootViewController = UIHostingController(rootView: LoginScreen())
                        }) {
                            HStack {
                                Image("logout")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 34)
                            }
                        }
                        .padding()
                        .frame(width: 35, height: 35)
                    }
                    Image("customerglu")
                }.frame(width: width, height: (height/4))
                    .foregroundColor(.black)
                    .navigationTitle("Home")
                    .navigationBarHidden(true)
                HStack {
                    Button(action: {
                        CustomerGlu.getInstance.openWallet()
                    }) {
                        productCard(image: "purse", title: "Wallet")
                    }
                    Spacer()
                    Button(action: {
                        self.isAlert = true
//                        CustomerGlu.getInstance.openWallet()
                    }) {
                        productCard(image: "coin", title: "Rewards")
                    }.alert(isPresented: $isAlert, AlertConfig(title: "CampaignId / Tag", placeholder: "Enter CampaignId / Tag", accept:"Open Campaign", action: {
                        if $0 != nil {
                                                    loadCampaignByID(campaignId: $0 ?? "")
                                                }
                    }))
                }.padding(.horizontal, 10)
                HStack {
                    Button(action: {
                        CustomerGlu.getInstance.openWalletWithURL(url: "https://games.customerglu.com/wallet/?token=demo_token")
                    }) {
                        productCard(image: "shop", title: "All campaigns")
                    }


                }.padding(.horizontal, 1)
                Spacer()
            }.onAppear(perform: {
//                CustomerGlu.getInstance.addBannerView(frame: CGRect(x: 0, y: 100, width: 300, height: 400))
//                CustomerGlu.getInstance.addBannerView(frame: CGRect(x: 50, y: 150, width: 200, height: 80))
            })
        }.ignoresSafeArea(.all)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
    
    func loadCampaignByID(campaignId: String) {
        
        if(!campaignId.isEmpty)
        {
            customerglu.loadCampaignById(campaign_id: campaignId)
            
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
