//
//  CartCell.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI

struct MyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
    
}
struct CartCell: View {
    
    var image: String
    var title: String
    var type: String
    var price: Double
    @State var liked = false
    var body: some View {
        HStack(alignment: .center) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding(.all, 20)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Text(type)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.black)
                HStack {
                    Text("$" + String.init(format: "%0.2f", price))
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .padding(.top, 8)
                }
            }.padding(.trailing, 20)
            Spacer()
            if liked
            {
                Button(action: {
                    self.liked.toggle()
                }, label: {
                        Image(systemName: "heart.fill").resizable()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30, alignment: .center)                    })
            }
            else
            {
                Button(action: {
                    self.liked.toggle()

                }, label: {
                        Image(systemName: "heart").resizable()
                            .frame(width: 30, height: 30, alignment: .center)                    })
            
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.white)
        .modifier(CardModifier())
        .padding(.all, 10)
        
    }
}
struct CartCell_Previews: PreviewProvider {
    static var previews: some View {
        CartCell(image: "trolley", title: "f", type: "cl", price: 20.0)
    }
}
