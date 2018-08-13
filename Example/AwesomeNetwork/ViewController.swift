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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        AwesomeNetwork.shared.addObserver(self, selector: #selector(networkConnected), event: .connected)
        AwesomeNetwork.shared.addObserver(self, selector: #selector(networkDisconnected), event: .disconnected)
        
    }
    
    @objc func networkConnected() {
        print("Executing CONNECTED")
        
    }
    
    @objc func networkDisconnected() {
        print("Executing DIS+CONNECTED")
        
    }
}

