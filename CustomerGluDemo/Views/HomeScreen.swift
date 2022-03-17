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
                        CustomerGlu.getInstance.loadAllCampaigns()
                    }) {
                        productCard(image: "coin", title: "Rewards")
                    }
                }.padding(.horizontal, 10)
                ZStack() {
                    Color.clear
                  //  BannerViewAdd()
                }.frame(width: width - 30, height: 110)
                    .navigationBarHidden(true)
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
              //  customerglu.addDragabbleView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
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

struct BannerViewAdd: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.addSubview(CustomerGlu.getInstance.addBannerViewNew(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 110)))
        return view
    }
}
