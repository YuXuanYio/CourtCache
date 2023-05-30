//
//  ViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/4/2023.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }

}

