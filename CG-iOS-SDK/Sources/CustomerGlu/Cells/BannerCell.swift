//
//  SwiftUIView.swift
//  
//
//  Created by Himanshu Trehan on 27/07/21.
//

#if canImport(Combine)
import SwiftUI
import Combine
import Foundation
import UIKit
@available(iOS 13.0, *)

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Foundation.Data, Never>()
    var data = Foundation.Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

//extension String
//{
//    func load()-> UIImage
//    {
//
//        do
//        {
//            guard let url = URL(string: self)
//
//            else
//            {
//                return UIImage()
//            }
//            let data:Foundation.Data = try Foundation.Data(contentsOf: url)
//
//            return UIImage(data: data)!
//
//        }
//        catch
//        {
//            print("not found")
//        }
//        return UIImage()
//    }
//}

@available(iOS 13.0, *)
struct BannerCell:View
{
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    var title:String
    var url:String
    
    
    init(image_url:String,title:String,url:String) {
        self.title = title
        self.url = url
        imageLoader = ImageLoader(urlString:image_url)
        
    }
    var body: some View
    {
        VStack(alignment: .center) {
                
            NavigationLink(destination: RewardWeb(url: url)) {
                Image(uiImage: image)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                    .frame(width:.infinity-40, height:100)
                               .onReceive(imageLoader.didChange) { data in
                               self.image = UIImage(data: data) ?? UIImage()
                       }
               // Image(uiImage: url.load())

            }
            Text(title).font(.system(size: 25)).padding(.bottom,10)
        }
        .frame(maxWidth: (.infinity-40), alignment: .center)
        .background(Color.white)
        .modifier(CardModifier())
        
    }
        
    
        
    }

@available(iOS 13.0, *)
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
            
            
    }
}
#endif
