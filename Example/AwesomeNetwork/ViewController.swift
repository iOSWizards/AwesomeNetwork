//
//  ViewController.swift
//  AwesomeNetwork
//
//  Created by evandro@itsdayoff.com on 02/15/2018.
//  Copyright (c) 2018 evandro@itsdayoff.com. All rights reserved.
//

import UIKit
import AwesomeNetwork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.listenToNetwork { (isConnected) in
            print("Network is Connected :\(isConnected)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AwesomeNetwork.shared.removeObserver(self)
    }
    
}

