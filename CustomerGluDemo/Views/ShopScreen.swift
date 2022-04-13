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
            .navigationTitle("Shop Screen")
        }.onAppear(perform: {
            
            CustomerGlu.getInstance.setCurrentClassNeme(className: String(describing: type(of: self)))
//                CustomerGlu.getInstance.setCurrentClassNeme(className: String(describing: self.self))
          //  customerglu.addDragabbleView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
        })
    }
}

struct ShopScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopScreen()
    }
}
