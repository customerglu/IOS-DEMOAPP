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
            
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    HStack {
                        Spacer()
                        Button(action: {
                            customerglu.resetDefaults()
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
