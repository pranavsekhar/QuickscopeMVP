//
//  RootNavigationViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/3/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBar.barTintColor = UIColor.init(red: 33/255.0, green: 34/255.0, blue: 35/255.0, alpha: 1.0)
        self.navigationBar.isTranslucent = false
        self.navigationBar.setValue(true, forKey: "hidesShadow")
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
