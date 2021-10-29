//
//  ProductListCell.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import CustomerGlu

@ViewBuilder func productListCell(image: String, title: String) -> some View {
    
    VStack(alignment: .center) {
        Image(image)
            .resizable()
            .frame(width: 100, height: 100, alignment: .center)
            .padding(.top, 20)
        Text(title).font(.system(size: 25)).padding(.bottom, 10)
        HStack {
            Spacer()
            //                NavigationLink(
            //                    destination: CartScreen(),
            //                    label: {
            //                        EmptyView()
            //                        Text("Add to Cart")
            //                            .font(.system(size: 15))
            //                            .frame(width: 80,
            //                                   height: 20,
            //                                   alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            //
            //                    })
            Text("Add to Cart")
                .onTapGesture {
                    CustomerGlu.single_instance.addToCart(eventName: "shop", eventProperties: ["state": "1"]) { success, addCartModel in
                        if success {
                            print(addCartModel as Any)
                        } else {
                            print("error")
                        }
                    }
                }
                .font(.system(size: 15))
                .frame(width: 80, height: 20, alignment: .center)
                .padding(.all, 10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
        }.padding([.trailing, .bottom], 10)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color.white)
    .modifier(CardModifier())
    .padding(.all, 10)
}

struct ProductListCell_Previews: PreviewProvider {
    static var previews: some View {
        productListCell(image: "trolley", title: "s")
    }
}
