//
//  ChartViewController.swift
//  CoreBluetoothExplorer
//
//  Created by João Souza on 13/10/2017.
//  Copyright © 2017 João Marcelo Souza. All rights reserved.
//

import UIKit

class QuickStartViewController: UIViewController, QuickStartDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    var quickStart: QuickStart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quickStart = QuickStart(delegate: self)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        quickStart.start()
    }
    
    func quickStartDidUpdateValue(quickStart _: QuickStart, value: Double) {
        print(value)
        label.text = String(describing: value)
    }
    
}
