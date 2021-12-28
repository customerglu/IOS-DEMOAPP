//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//
import Foundation
import UIKit

class BannerCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImageAndTitle(image_url: String, title: String) {
      //  shadowView.dropShadow()
        imgView.downloadImage(urlString: image_url)
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
