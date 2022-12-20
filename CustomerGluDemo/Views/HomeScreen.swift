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
            ScrollView {
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
                        
                        let nudgeConfiguration = CGNudgeConfiguration()
                        nudgeConfiguration.closeOnDeepLink = false
                        nudgeConfiguration.opacity = -0.0
                        nudgeConfiguration.layout = "bottom-default"
//                        nudgeConfiguration.layout = "middle-popup"
//                        nudgeConfiguration.layout = "bottom-slider"
//                        nudgeConfiguration.layout = "full-default"
                        nudgeConfiguration.absoluteHeight = -0.0
                        nudgeConfiguration.relativeHeight = 40.0
                        
//                        nudgeConfiguration.url = "https://coindcx.end-ui.customerglu.com/reward/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnbHUtdGVzdC0wMTIzIiwiZ2x1SWQiOiI4YTUwZTVmOS00YzY2LTQ5MGItODNlNi00OTU3ZGI2ZTkyNDAiLCJjbGllbnQiOiJjOThkNWEwNC1kZTljLTRmYTQtYjVhZC0zN2RmOGZhMzk3NWMiLCJkZXZpY2VJZCI6ImdsdS10ZXN0LTAxMjNfZGVmYXVsdCIsImRldmljZVR5cGUiOiJkZWZhdWx0IiwiaXNMb2dnZWRJbiI6dHJ1ZSwiaWF0IjoxNjY4MDc4MDcyLCJleHAiOjE2OTk2MTQwNzJ9.gLuNKYD04TYeziH7ia-77_D7s0tydsF7TCYQZzrxSio&rewardUserId=0958ae55-54a5-412e-ba73-883119fd62a5"
                        
//                        CustomerGlu.getInstance.openWalletWithURL(url: "https://q6305i.csb.app/")
//                        nudgeConfiguration.absoluteHeight = 600
//                        nudgeConfiguration.relativeHeight = 20.0

//                        CustomerGlu.getInstance.configureSafeArea(topHeight: 35, bottomHeight: 34, topSafeAreaColor:.systemPink, bottomSafeAreaColor: .brown)
//                        CustomerGlu.getInstance.configureLoadingScreenColor(color: UIColor(red: 255.0, green: 255.0, blue: 0.0, alpha: 1.0))
                        CustomerGlu.getInstance.openWallet(nudgeConfiguration: nudgeConfiguration)

                        
//                        CustomerGlu.getInstance.openNudge(nudgeId: "referral-fragment", nudgeConfiguration: nudgeConfiguration)
                        
//                        CustomerGlu.getInstance.loadCampaignById(campaign_id: "bf63e1f4-90c3-42a9-ad95-ef98226758ac", nudgeConfiguration: nudgeConfiguration)
//                        CustomerGlu.getInstance.loadCampaignById(campaign_id: "", auto_close_webview: false)
//                        CustomerGlu.getInstance.openNudge(nudgeId: "referral-fragment", layout: "middle-popup", bg_opacity: 0.1)
//                        CustomerGlu.getInstance.openNudge(nudgeId: <#T##String#>, layout: <#T##String#>, bg_opacity: <#T##Double#>, closeOnDeeplink: <#T##Bool#>)
//                        CustomerGlu.getInstance.openWallet()
//                        CustomerGlu.getInstance.openWalletWithURL(url:"https://tatacliq.end-ui.customerglu.com/fragment-map/?fragmentMapId=referral-fragment&userId=glutest-3222&writeKey=4Qu4j4oMnirDEdoQsJlSaQsgoXuFjrG3lTgrRqMj")
//                        CustomerGlu.getInstance.openWalletWithURL(nudgeConfiguration: nudgeConfiguration)
                    }) {
                        productCard(image: "purse", title: "Wallet")
                    }
                    Spacer()
                    Button(action: {
//                        CustomerGlu.getInstance.loadAllCampaigns()
                        
                        let nudgeConfiguration = CGNudgeConfiguration()
                        nudgeConfiguration.closeOnDeepLink = false
                        nudgeConfiguration.opacity = 0.9
                        nudgeConfiguration.layout = "bottom-default"
//                        nudgeConfiguration.url = "http://google.com/"
                        nudgeConfiguration.absoluteHeight = 100
                        nudgeConfiguration.relativeHeight = 70
                        
//                        CustomerGlu.getInstance.openWallet(nudgeConfiguration: nudgeConfiguration)
                        customerglu.openNudge(nudgeId: "nudgeId", nudgeConfiguration: nudgeConfiguration);
                    }) {
                        productCard(image: "coin", title: "Rewards")
                    }
                }.padding(.horizontal, 10)
                VStack {
                    BannerViewAdd()
//                    EmbedViewAdd()
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
                CustomerGlu.getInstance.setCurrentClassName(className: String(describing: type(of: self)))
            })
            
        }
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
    func updateUIView(_ uiView: BannerView, context: Context) {
    }
    
    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), bannerId: "entry1") //cart_banner
        view.setContentHuggingPriority(.required, for: .horizontal) // << here !!
        view.setContentHuggingPriority(.required, for: .vertical)
        // the same for compression if needed
        return view
    }
}

struct EmbedViewAdd: UIViewRepresentable {
    func updateUIView(_ uiView: CGEmbedView, context: Context) {
    }
    
    func makeUIView(context: Context) -> CGEmbedView {
        let view = CGEmbedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), embedId: "embedded1")
        view.setContentHuggingPriority(.required, for: .horizontal) // << here !!
        view.setContentHuggingPriority(.required, for: .vertical)
        // the same for compression if needed
        return view
    }
}

