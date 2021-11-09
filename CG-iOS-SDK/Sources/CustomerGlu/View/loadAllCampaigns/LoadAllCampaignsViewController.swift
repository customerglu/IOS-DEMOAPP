//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit

public class LoadAllCampaignsViewController: UIViewController {
    
    public static let storyboardVC = UIStoryboard(name: "Storyboard", bundle: .module).instantiateViewController(withIdentifier: "LoadAllCampaignsViewController")

    @IBOutlet weak var tblRewardList: UITableView!
    var campaigns: [Campaigns] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tblRewardList.rowHeight = UITableView.automaticDimension
        tblRewardList.estimatedRowHeight = 200
        
        getCampaign()
    }
    
    func getCampaign() {
        CustomerGlu.single_instance.getWalletRewards { success, campaignsModel in
            if success {
                self.campaigns = (campaignsModel?.campaigns)!
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.tblRewardList.reloadData()
                }
            } else {
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "getCampaigns", exception: "error")
            }
        }
    }
}

extension LoadAllCampaignsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Tableview Data Source Methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaigns.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "BannerCellNew"
        var cell: BannerCellNew! = tblRewardList.dequeueReusableCell(withIdentifier: identifier) as? BannerCellNew
        if cell == nil {
            tblRewardList.register(UINib(nibName: "BannerCellNew", bundle: .module), forCellReuseIdentifier: identifier)
            cell = tblRewardList.dequeueReusableCell(withIdentifier: identifier) as? BannerCellNew
        }

        if campaigns.count != 0 {
            // Populate cell Data
            configureCell(cell: cell, indexPath: indexPath)
        }

        cell.clipsToBounds = true
        cell.layer.cornerRadius = 12
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        return cell
    }
    
    // MARK: - Populate data in cell.
    private func configureCell(cell: BannerCellNew, indexPath: IndexPath) {
        // Populate cell Data
        
        let element = campaigns[indexPath.row]
        
        if element.banner != nil {
            if element.banner?.imageUrl == nil && element.banner?.title == nil {
                cell.setImageAndTitle(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: "")
            } else if element.banner?.imageUrl == nil {
                cell.setImageAndTitle(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: (element.banner?.title)!)
            } else if element.banner?.title == nil {
                cell.setImageAndTitle(image_url: (element.banner?.imageUrl!)!, title: "")
            } else {
                cell.setImageAndTitle(image_url: (element.banner?.imageUrl!)!, title: (element.banner?.title!)!)
            }
        } else {
            cell.setImageAndTitle(image_url: "https://images.unsplash.com/photo-1614680376739-414d95ff43df?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGdhbWVzJTIwYmFubmVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60", title: "")
        }
        cell.selectionStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect Table Row
        tableView.deselectRow(at: indexPath, animated: true)
        if campaigns.count != 0 {
            let customerWebViewVC = UIStoryboard(name: "Storyboard", bundle: .module).instantiateViewController(withIdentifier: "CustomerWebViewController") as? CustomerWebViewController
            customerWebViewVC!.urlStr = campaigns[indexPath.row].url
            self.navigationController?.pushViewController(customerWebViewVC!, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
