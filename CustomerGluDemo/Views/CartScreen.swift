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
        VStack {
            CartCell(image: "donut", title: "Donut", type: "Snacks", price: 20)
            CartCell(image: "apple", title: "Apple", type: "Snacks", price: 10)
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
                        CustomerGlu.getInstance.sendEventData(eventName: "completePurchase1", eventProperties: ["state": "1"])
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
            
            CustomerGlu.getInstance.setCurrentClassNeme(className: String(describing: type(of: self)))
//                CustomerGlu.getInstance.setCurrentClassNeme(className: String(describing: self.self))
          //  customerglu.addDragabbleView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
        })
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
