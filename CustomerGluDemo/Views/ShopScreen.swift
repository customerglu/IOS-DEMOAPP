//
//  ShopScreen.swift
//  CustomerGluDemoApp
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import CustomerGlu

struct ShopScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let data = Array(1...20).map {
        "Items \($0)"
    }
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(data, id: \.self) { _ in
                    productListCell(image: "trolley", title: "Shop")
                }
            }
            .navigationTitle("ShoppingScreen")
        }.onAppear(
            perform: {
                CustomerGlu.getInstance.setCurrentClassName(className: "ShoppingScreen")
            })
    }
}

struct ShopScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopScreen()
    }
}
