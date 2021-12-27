//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit

public class LoadAllCampaignsViewController: UIViewController {
        
    public static let storyboardVC = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)

    @IBOutlet weak var tblRewardList: UITableView!
    var campaigns: [Campaigns] = []
    var bannerDefaultUrl = CustomerGlu.defaultBannerUrl
    var loadCampignType = ""
    var loadCampignValue = ""
    var loadByparams = NSDictionary()
    
    // MARK: - Variables
    private var loadAllCampaignsViewModel = LoadAllCampaignsViewModel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tblRewardList.rowHeight = UITableView.automaticDimension
        tblRewardList.estimatedRowHeight = 200
        
        if ApplicationManager.doValidateToken() == true {
            getCampaign()
        } else {
            loadAllCampaignsViewModel.updateProfile { success, _ in
                if success {
                    self.getCampaign()
                } else {
                    print("error")
                }
            }
        }
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCampaign() {
        CustomerGlu.getInstance.loaderShow(withcoordinate: self.view.frame.midX - 30, y: self.view.frame.midY - 30)
                
        ApplicationManager.loadAllCampaignsApi(type: loadCampignType, value: loadCampignValue, loadByparams: loadByparams) { success, campaignsModel in
            if success {
                CustomerGlu.getInstance.loaderHide()
                self.campaigns = (campaignsModel?.campaigns)!
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.tblRewardList.reloadData()
                }
            } else {
                CustomerGlu.getInstance.loaderHide()
                print("error")
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
        
        let identifier = TableViewID.BannerCell
        var cell: BannerCell! = tblRewardList.dequeueReusableCell(withIdentifier: identifier) as? BannerCell
        if cell == nil {
            tblRewardList.register(UINib(nibName: TableViewID.BannerCell, bundle: .module), forCellReuseIdentifier: identifier)
            cell = tblRewardList.dequeueReusableCell(withIdentifier: identifier) as? BannerCell
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
    private func configureCell(cell: BannerCell, indexPath: IndexPath) {
        // Populate cell Data
        
        let element = campaigns[indexPath.row]
        
        if element.banner != nil {
            if element.banner?.imageUrl == nil && element.banner?.title == nil {
                cell.setImageAndTitle(image_url: bannerDefaultUrl, title: "")
            } else if element.banner?.imageUrl == nil {
                cell.setImageAndTitle(image_url: bannerDefaultUrl, title: (element.banner?.title)!)
            } else if element.banner?.title == nil {
                cell.setImageAndTitle(image_url: (element.banner?.imageUrl!)!, title: "")
            } else {
                cell.setImageAndTitle(image_url: (element.banner?.imageUrl!)!, title: (element.banner?.title!)!)
            }
        } else {
            cell.setImageAndTitle(image_url: bannerDefaultUrl, title: "")
        }
        cell.selectionStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect Table Row
        tableView.deselectRow(at: indexPath, animated: true)
        if campaigns.count != 0 {
            let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
            customerWebViewVC.urlStr = campaigns[indexPath.row].url
            self.navigationController?.pushViewController(customerWebViewVC, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
