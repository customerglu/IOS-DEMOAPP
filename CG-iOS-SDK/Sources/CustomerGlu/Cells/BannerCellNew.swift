//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//
import Foundation
import UIKit

class BannerCellNew: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImageAndTitle(image_url: String, title: String) {
        do {
            let url = URL(string: image_url)
            let data = try Data(contentsOf: url!)
            imgView.image = UIImage(data: data)
        }
        catch{
            print(error)
        }
        
        titleLbl.text = title
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
