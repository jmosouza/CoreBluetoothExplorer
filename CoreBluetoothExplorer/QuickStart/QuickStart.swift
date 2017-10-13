//
//  DeviceLinker.swift
//  CoreBluetoothExplorer
//
//  Created by João Souza on 13/10/2017.
//  Copyright © 2017 João Marcelo Souza. All rights reserved.
//

import CoreBluetooth

class QuickStart: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var isOn: Bool!
    
    // Subscribe to notifications
    var delegate: QuickStartDelegate?
    
    // CoreBluetooth Central Manager
    var centralManager: CBCentralManager!
    
    // Peripheral chosen by user
    var peripheral: CBPeripheral?
    var service: CBService?
    var characteristic: CBCharacteristic?
    
    // Expected service
    let serviceUUID = CBUUID(string: "D0611E78-BBB4-4591-A5F8-487910AE4366")
    let characteristicUUID = CBUUID(string: "8667556C-9A37-4C91-84ED-54EE27D90049")
    
    init(delegate: QuickStartDelegate?) {
        super.init()
        self.delegate = delegate
        // This will trigger centralManagerDidUpdateState
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start() {
        isOn = true
        scan()
    }
    
    func stop() {
        isOn = false
        centralManager.stopScan()
    }
    
    private func scan() {
        guard isOn else {
            print("Can't scan because QuickStart is off")
            return
        }
        
        guard centralManager.state == .poweredOn else {
            print("Can't scan because CBCentralManager is off")
            return
        }
        
        clear()
        
        print("Scanning...")
        // Scan for peripherals with the specified services
        // MARK: TODO specifying the services is not working
        let services = [serviceUUID]
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        centralManager.scanForPeripherals(withServices: [], options: options)
    }
    
    private func clear() {
        if let p = peripheral {
            centralManager.cancelPeripheralConnection(p)
        } else {
            peripheral = nil
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager did update state")
        
        // Give feedback
        var message = String()
        switch central.state {
        case .poweredOn:
            scan()
            message = "Bluetooth is powered on"
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
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral discovered: \(peripheral.identifier.uuidString)")
        if nil == self.peripheral {
            centralManager.connect(peripheral, options: nil)
            self.peripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected: \(peripheral.identifier.uuidString)")
        // MARK: TODO specifying the services is not working
        let services = [serviceUUID]
        peripheral.delegate = self
        peripheral.discoverServices([])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect: \(peripheral.identifier.uuidString)")
    }
    
    
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services in peripheral: \(peripheral.identifier.uuidString)")
        
        if let e = error {
            clear()
            print("Failed to discover services: \(e.localizedDescription)")
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            clear()
            print("Failed to find expected service in peripheral: \(peripheral.identifier.uuidString)")
            return
        }
        
        let characteristics = [characteristicUUID]
        peripheral.discoverCharacteristics(characteristics, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics in service \(service.uuid.uuidString) in peripheral: \(peripheral.identifier.uuidString)")
        
        if let e = error {
            clear()
            print("Failed to discover characteristics: \(e.localizedDescription)")
            return
        }
        
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            clear()
            print("Failed to find expected characteristic in service: \(service)")
            return
        }
        
        centralManager.stopScan()
        peripheral.setNotifyValue(true, for: characteristic)
        
        // Keep all references
        self.peripheral = peripheral
        self.service = service
        self.characteristic = characteristic
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Updated value in characteristic \(characteristic.uuid.uuidString) in peripheral: \(peripheral.identifier.uuidString)")
        
        if let e = error {
            print("Failed to update value for characteristic: \(e.localizedDescription)")
            return
        }
        
        print("Value for characteristic \(characteristic.uuid.uuidString) is: \(characteristic.value)")
        let parsedData = String(data: characteristic.value!, encoding: String.Encoding.utf8)
        print("Parsed value for characteristic \(characteristic.uuid.uuidString) is: \(parsedData)")
        
        delegate?.quickStartDidUpdateValue(quickStart: self, value: Double(arc4random() / 100_000))
    }
    
    
    
}


