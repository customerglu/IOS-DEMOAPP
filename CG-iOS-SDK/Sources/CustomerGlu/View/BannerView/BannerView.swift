//
//  File.swift
//
//
//  Created by kapil on 1/2/22.
//

import UIKit
import Foundation

public class BannerView: UIView, UIScrollViewDelegate {
    
    var view = UIView()
    
    @IBOutlet weak var imgScrollView: UIScrollView!
    var sliderImagesArray = NSMutableArray()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        xibSetup()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        xibSetup()
        configure()
    }
    
    private func configure() {
        // imgView.downloadImage(urlString: "https://assets.customerglu.com/demo/quiz/banner-image/Quiz_1.png")
        sliderImagesArray = ["https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080", "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080", "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080"]
       // ,"https://i.gifer.com/origin/41/41297901c13bc7325dc7a17bba585ff9_w200.gif"
        
        imgScrollView.delegate = self
        for i in 0..<sliderImagesArray.count {
            var imageView: UIImageView
            let xOrigin = self.imgScrollView.frame.size.width * CGFloat(i)
            imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: self.imgScrollView.frame.size.width, height: self.imgScrollView.frame.size.height))
            imageView.isUserInteractionEnabled = true
            imageView.tag = i
            let urlStr = sliderImagesArray.object(at: i)
            
            let imageExtensions = ["gif"]
            // Iterate & match the URL objects from your checking results
            let url: URL? = NSURL(fileURLWithPath: urlStr as! String) as URL
            let pathExtention = url?.pathExtension
            if imageExtensions.contains(pathExtention!) {
                // Do something with it
                let imageURL = UIImage.gifImageWithURL(urlStr as! String)
                imageView = UIImageView(image: imageURL)
            } else {
                imageView.downloadImage(urlString: urlStr as! String)
            }
            
            imageView.contentMode = .scaleToFill
            self.imgScrollView.addSubview(imageView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            imageView.addGestureRecognizer(tap)
        }
        self.imgScrollView.isPagingEnabled = true
        self.imgScrollView.bounces = false
        self.imgScrollView.showsVerticalScrollIndicator = false
        self.imgScrollView.showsHorizontalScrollIndicator = false
        self.imgScrollView.contentSize = CGSize(width:
                                                    self.imgScrollView.frame.size.width * CGFloat(sliderImagesArray.count), height: self.imgScrollView.frame.size.height)
        
        // Timer in viewdidload()
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveToNextImage), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextImage() {
        let imgsCount: CGFloat = CGFloat(sliderImagesArray.count)
        let pageWidth: CGFloat = self.imgScrollView.frame.width
        let maxWidth: CGFloat = pageWidth * imgsCount
        let contentOffset: CGFloat = self.imgScrollView.contentOffset.x
        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0
        }
        self.imgScrollView.scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height: self.imgScrollView.frame.height), animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print(sender?.view?.tag ?? 0)
        self.removeFromSuperview()
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: "https://stackoverflow.com/questions/43714948/draggable-uiview-swift-3", page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: 0.5)
    }
    
    // MARK: - Nib handlers
    private func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        imgScrollView.frame = bounds
        imgScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "BannerView", bundle: .module)
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view!
    }
}
