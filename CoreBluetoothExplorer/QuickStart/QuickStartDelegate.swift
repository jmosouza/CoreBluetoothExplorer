//
//  QuickStartDelegate.swift
//  CoreBluetoothExplorer
//
//  Created by João Souza on 13/10/2017.
//  Copyright © 2017 João Marcelo Souza. All rights reserved.
//

protocol QuickStartDelegate {
    
    /// This method is called whenever the peripheral sends a new reading.
    func quickStartDidUpdateValue(quickStart: QuickStart, value: Double)
}
