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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AwesomeNetwork.shared?.addObserver(self, selector: #selector(networkConnected), event: .connected)
    }
    
    @objc func networkConnected() {
        print("Executing CONNECTED")
        
    }
}

