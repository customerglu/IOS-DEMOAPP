//
//  CartScreen.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
//extension UIApplication{
//static var keyWin: UIWindow? {
//    if #available(iOS 13, *) {
//        return UIApplication.shared.windows.first { $0.isKeyWindow }
//    } else {
//        return UIApplication.shared.keyWindow
//    }
//}
//}
struct CartScreen: View {
    @State var active = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {

        VStack{
        
            CartCell(image: "donut", title: "Donut", type: "Snacks", price: 20)
            CartCell(image: "apple", title: "Apple", type: "Snacks", price: 10)
            Spacer()
            HStack
            {
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
            ZStack
            {
                Color.black
           HStack
           {
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
                TestController()
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
