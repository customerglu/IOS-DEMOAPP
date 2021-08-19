//
//  ViewController.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 03/08/21.
//

import Foundation
import UIKit
import SwiftUI
import CustomerGlu

//storyboard to swiftUI


class ViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func OpenSwift(_ sender: Any) {
        print("connected")
        CustomerGlu().loadAllCampaignsUiKit(cus_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnbHUiLCJnbHVJZCI6IjIzZmRkOWU0LWRjYWMtNDlkYS1hMWI5LThmYWRjOGU2YWZkNSIsImNsaWVudCI6Ijg0YWNmMmFjLWIyZTAtNDkyNy04NjUzLWNiYTJiODM4MTZjMiIsImRldmljZUlkIjoiZGV2aWNlYiIsImRldmljZVR5cGUiOiJhbmRyb2lkIiwiaWF0IjoxNjI4MDY0NzYxLCJleHAiOjE2NTk2MDA3NjF9.x86E0pKN2n_nc_If6nqL3CsxGql78q4ehtgwbUdaAwg")
    }
   
    @IBAction func wallet(_ sender: UIButton) {
        CustomerGlu().openUiKitWallet(cus_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnbHUiLCJnbHVJZCI6IjIzZmRkOWU0LWRjYWMtNDlkYS1hMWI5LThmYWRjOGU2YWZkNSIsImNsaWVudCI6Ijg0YWNmMmFjLWIyZTAtNDkyNy04NjUzLWNiYTJiODM4MTZjMiIsImRldmljZUlkIjoiZGV2aWNlYiIsImRldmljZVR5cGUiOiJhbmRyb2lkIiwiaWF0IjoxNjI4MDY0NzYxLCJleHAiOjE2NTk2MDA3NjF9.x86E0pKN2n_nc_If6nqL3CsxGql78q4ehtgwbUdaAwg")
    }
    
//    func presentSwiftUIView(view:AnyView) {
//
//        let swiftUIView = OpenWallet(cus_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnbHUiLCJnbHVJZCI6IjIzZmRkOWU0LWRjYWMtNDlkYS1hMWI5LThmYWRjOGU2YWZkNSIsImNsaWVudCI6Ijg0YWNmMmFjLWIyZTAtNDkyNy04NjUzLWNiYTJiODM4MTZjMiIsImRldmljZUlkIjoiZGV2aWNlYiIsImRldmljZVR5cGUiOiJhbmRyb2lkIiwiaWF0IjoxNjI4MDY0NzYxLCJleHAiOjE2NTk2MDA3NjF9.x86E0pKN2n_nc_If6nqL3CsxGql78q4ehtgwbUdaAwg")
//    //UIHostingController
////        UINavigationController(rootViewController: UIViewController)
//        let hostingController = UIHostingController(rootView: swiftUIView)
//        hostingController.modalPresentationStyle = .fullScreen
//
////       self.navigationController?.pushViewController(hostingController, animated: true)
//
//        UIApplication.keyWin?.rootViewController?.present(hostingController, animated: true, completion: nil)
//
//    }
    
 
    
    
}
