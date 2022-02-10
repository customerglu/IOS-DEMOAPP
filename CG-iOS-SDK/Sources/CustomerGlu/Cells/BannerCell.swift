//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//
import Foundation
import UIKit

class BannerCell: UITableViewCell {
    
    var imgView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let boxView = UIView.init(frame: CGRect(x: 10 , y: 10 , width: UIScreen.main.bounds.size.width - 10*2, height: 130))
        self.contentView.backgroundColor = UIColor.clear
        boxView.backgroundColor = UIColor.white
        self.contentView.addSubview(boxView)
        
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: boxView.frame.width, height: boxView.frame.height))
        imgView.contentMode = .scaleToFill
        boxView.addSubview(imgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setImageAndTitle(image_url: String, title: String) {
        //  shadowView.dropShadow()
        imgView.downloadImage(urlString: image_url)
    }
}
