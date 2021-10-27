//
//  ProductCard.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI

@ViewBuilder func productCard(image: String, title: String) -> some View {
    
    VStack(alignment: .center) {
        Image(image)
            .resizable()
            .frame(width: 120, height: 110, alignment: .center)
            .padding()
        Text(title).font(.system(size: 25)).padding(.bottom, 10).foregroundColor(.black)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color.white)
    .modifier(CardModifier())
    .padding(.all, 10)
}

@ViewBuilder func customTextFields(label: String, image: String, key: Binding<String>) -> some View {
    HStack {
        Image(systemName: image).foregroundColor(.blue).padding()
        TextField(label, text: key)
    }.frame(height: 60)
        .background(Color.white)
        .cornerRadius(30)
        .padding()
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        productCard(image: "trolley", title: "Shop")
    }
}
