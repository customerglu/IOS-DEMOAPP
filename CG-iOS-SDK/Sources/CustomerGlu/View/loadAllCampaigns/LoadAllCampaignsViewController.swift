//
//  File.swift
//
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit

public class LoadAllCampaignsViewController: UIViewController {
        
    var campaigns: [Campaigns] = []
    var bannerDefaultUrl = CustomerGlu.defaultBannerUrl
    var loadCampignType = ""
    var loadCampignValue = ""
    var loadByparams = NSDictionary()
    var tblRewardList = UITableView()
    
    var topSafeArea = UIView()
    var bottomSafeArea = UIView()
    var topHeight = Int()
    var bottomHeight = Int()
    
    // MARK: - Variables
    private var loadAllCampaignsViewModel = LoadAllCampaignsViewModel()
    
    public func configureSafeAreaForDevices() {
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top)!
        let bottomPadding = (window?.safeAreaInsets.bottom)!

        if topPadding <= 20 || bottomPadding < 20 {
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
            CustomerGlu.topSafeAreaColor = UIColor.clear
        }

        topHeight = CustomerGlu.topSafeAreaHeight
        bottomHeight = CustomerGlu.bottomSafeAreaHeight
        topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColor
        bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColor
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .white
        
        self.configureSafeAreaForDevices()
        
        topSafeArea = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: topHeight))
        self.view.addSubview(topSafeArea)
        
        let headerView = UIView(frame: CGRect(x: 0, y: topHeight, width: Int(self.view.frame.width), height: 44))
        headerView.backgroundColor = .white
        self.view.addSubview(headerView)
       
        let backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 44))
        backBtn.setTitle("Back", for: .normal)
        backBtn.setTitleColor(.blue, for: .normal)
        backBtn.addTarget(self, action: #selector(self.backButton), for: .touchUpInside)
        headerView.addSubview(backBtn)

        let nameLabel = UILabel(frame:CGRect(x:self.view.frame.midX - 60 , y:0 , width: 120 , height: 44))
        nameLabel.text = "Campaigns"
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .center
        headerView.addSubview(nameLabel)
        
        bottomSafeArea = UIView(frame: CGRect(x: 0, y: Int(self.view.frame.height - CGFloat(bottomHeight)), width: Int(self.view.frame.width), height: bottomHeight))
        self.view.addSubview(bottomSafeArea)
        
        tblRewardList = UITableView(frame: CGRect(x: 0, y: Int(headerView.frame.maxY), width: Int(self.view.frame.width), height: Int(self.view.frame.height) - (topHeight + bottomHeight + 44)))
        tblRewardList.register(BannerCell.self, forCellReuseIdentifier: TableViewID.BannerCell)
        tblRewardList.delegate = self
        tblRewardList.dataSource = self
        tblRewardList.backgroundColor = .white
        self.view.addSubview(tblRewardList)
        
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
        CustomerGlu.getInstance.loaderShow(withcoordinate: view.frame.midX - 30, y: view.frame.midY - 30)
                
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
        
        let cell = tblRewardList.dequeueReusableCell(withIdentifier: TableViewID.BannerCell, for: indexPath as IndexPath) as! BannerCell
        
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
            let customerWebViewVC = CustomerWebViewController()
            customerWebViewVC.urlStr = campaigns[indexPath.row].url
            self.navigationController?.pushViewController(customerWebViewVC, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
