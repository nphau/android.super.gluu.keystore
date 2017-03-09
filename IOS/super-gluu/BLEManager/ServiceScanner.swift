//
//  ServiceScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceScanner: NSObject {
    
    var discovering = true
    
    var peripheral: CBPeripheral!
    var advertisementDataUUIDs: [CBUUID]?
    
//    let scanner = BackgroundScanner.defaultScanner
    
    override init() {
        super.init()
        
    }
    
}

extension ServiceScanner : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            NSLog("didDiscoverServices error: \(error.localizedDescription)")
        } else {
            NSLog("didDiscoverServices \(peripheral.services?.count)")
        }
        discovering = false
//        tableView.reloadData()
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            NSLog("didDiscoverCharacteristicsForService error: \(error.localizedDescription)")
        } else {
            NSLog("didDiscoverCharacteristicsForService \(service.characteristics?.count)")
//            if let row = peripheral.services?.index(of: service) {
//                let indexPath = IndexPath(row: row, section: 1)
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didWriteValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateNotificationStateForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic)
        }
    }

}
