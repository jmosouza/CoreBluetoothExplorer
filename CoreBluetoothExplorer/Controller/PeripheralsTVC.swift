//
//  PeripheralsTVC.swift
//  BluetoothDiscovery
//
//  Created by João Marcelo on 19/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralsTVC: UITableViewController, CBCentralManagerDelegate {

    // CoreBluetooth Central Manager
    var centralManager:CBCentralManager!
    
    // All peripherals in Central Manager
    var peripherals = [CBPeripheral]()
    
    // Peripheral chosen by user
    var peripheral:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This will trigger centralManagerDidUpdateState
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Re-start scan after coming back from background
        if centralManager.state == .poweredOn {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            centralManager.scanForPeripherals(withServices: nil, options: options)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Stop scan to save battery when entering background
        centralManager.stopScan()
        
        // Remove all peripherals from the table and array (they will be re-discovered upon viewDidAppear)
        peripherals.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager did update state")
        
        if (central.state == .poweredOn) {
            print("Bluetooth is powered on")
            
            // Scan for any peripherals
//            let uuid = CBUUID(string: "58A45811-B0F7-648B-E90A-B6046BC8F78C")
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            centralManager.scanForPeripherals(withServices: nil, options: options)
        }
        else {
            // Bluetooth is unavailable for some reason
            
            // Give feedback
            var message = String()
            switch central.state {
            case .unsupported:
                message = "Bluetooth is unsupported"
            case .unknown:
                message = "Bluetooth state is unkown"
            case .unauthorized:
                message = "Bluetooth is unauthorized"
            case .poweredOff:
                message = "Bluetooth is powered off"
            default:
                break
            }
            print(message)
            
            UIAlertView(
                title: "Bluetooth unavailable",
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral discovered: \(peripheral)")
        
        // Add the peripheral to the array to keep reference, otherwise the system will release it and further delegate methods won't be triggered (didConnect, didFail...)
        peripherals.append(peripheral)
        self.tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected: \(peripheral)")
        
        centralManager.stopScan()
        
        // Keep reference to be used in prepareForSegue
        self.peripheral = peripheral
        performSegue(withIdentifier: "Services", sender: self)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect: \(peripheral)")
        
        // Give feedback
        UIAlertView(
            title: "Peripheral failed",
            message: "Peripheral failed to connect: \(error?.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK")
            .show()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Peripheral", for: indexPath)

        let p = peripherals[indexPath.row]
        cell.textLabel?.text = p.name ?? "[Unkown name]"
        cell.detailTextLabel?.text = "UUID: \(p.identifier.uuidString)"

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = peripherals[indexPath.row]
        print("User selected peripheral \(selectedPeripheral)")
        centralManager.connect(selectedPeripheral, options: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let servicesTVC = segue.destination as! ServicesTVC
        servicesTVC.peripheral = self.peripheral
    }

}
