//
//  CartScreen.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import CustomerGlu

struct CartScreen: View {
    
    @State var active = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ScrollView {
        VStack {
            CartCell(image: "donut", title: "Donut", type: "Snacks", price: 20)
            CartCell(image: "apple", title: "Apple", type: "Snacks", price: 10)
            Spacer()
                VStack {
                    EmbedViewAdd()
                }
            Spacer()

            HStack {
                Spacer()
                Text("Total")
                    .font(.system(size: 30))
                    .bold()
                    .padding()
                Spacer()
                Spacer()
                Text("$30")
                    .font(.system(size: 30))
                    .bold()
                    .padding()
                Spacer()
            }
            ZStack {
                Color.black
                HStack {
                    //            NavigationLink(
                    //                destination: HomeScreen(),
                    //                isActive:$active,
                    //                label: {
                    //                    Text("CheckOut")
                    //                        .font(.system(size: 20))
                    //                        .bold()
                    //
                    //                })
                    Button(action: {
                        CustomerGlu.getInstance.sendEventData(eventName: "completePurchase2", eventProperties: ["state": "1"])
                    }, label: {
                        Text("CheckOut")
                            .font(.system(size: 20))
                            .bold()
                    })
                }
            }
            .frame(height: 60)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding()
        }.navigationTitle("My Cart")
        .onAppear(perform: {
            CustomerGlu.getInstance.setCurrentClassName(className: "Cart")
        })}
    }
}

struct CartScreen_Previews: PreviewProvider {
    static var previews: some View {
        CartScreen()
    }
}
//https://stackoverflow.com/questions/60677622/how-to-display-image-from-a-url-in-swiftui

struct TestController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Register", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "CartScreen")
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

//struct EmbedViewAdd: UIViewRepresentable {
//    func updateUIView(_ uiView: CGEmbedView, context: Context) {
//    }
//
//    func makeUIView(context: Context) -> CGEmbedView {
//        let view = CGEmbedView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-40, height: 0), embedId: "embedded1")
//        view.setContentHuggingPriority(.required, for: .horizontal) // << here !!
//        view.setContentHuggingPriority(.required, for: .vertical)
//        // the same for compression if needed
//        return view
//    }
//}

