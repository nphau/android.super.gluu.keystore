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
    
    var characteristicScanner : CharacteristicScanner!
    
//    let scanner = BackgroundScanner.defaultScanner
    
    override init() {
        super.init()
        
        characteristicScanner = CharacteristicScanner()
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
//            NSLog("didDiscoverCharacteristicsForService - \(service.description), uuid -- \(service.uuid), --- \(service.characteristics?.count)")
            
            //There we should discover characteristics for FFFD service for now
//            if service.uuid.uuidString == Constants.FFFD {//|| service.uuid.uuidString == Constants.Battery {
            //Discover whole services
//                NSLog("Start discover characteristics for service \(service.uuid.uuidString)")
//                characteristicScanner.service = service
//                characteristicScanner.peripharal = self.peripheral
//                characteristicScanner.discoverCharacteristics()
            
            
            for characteristic in service.characteristics! {
                print("Available value for -- \(characteristic) and characteristic.uuid.uuidString -- \(characteristic.uuid.uuidString)")
                if characteristic.uuid.uuidString == "2A26" || characteristic.uuid.uuidString == "2A19" || characteristic.uuid.uuidString == "2A27" || characteristic.uuid.uuidString == "2A50" || characteristic.uuid.uuidString == "2A24" || characteristic.uuid.uuidString == "2A28" {//|| characteristic.uuid.uuidString == "2A28" {//"2A19" -- "Battery Level"
                    let character = characteristic as CBCharacteristic
                    let type = getTypeOfCahracteristic(characteristic: character)
                    self.doAction(prop: type, characteristic: character)
                }
                //            }
            }
//            }
        }
    }
    
    func doAction(prop : CBCharacteristicProperties, characteristic: CBCharacteristic) {
        switch prop {
        case CBCharacteristicProperties.read:
//            print("Trying to read value for -- \(characteristic)")
            peripheral.readValue(for: characteristic)
//            requesting = true
            //        case CBCharacteristicProperties.write:
            //            if let value = "000000".data(using: String.Encoding.utf8) {
            //                print("Trying to write password for pairing maybe -- \(characteristic)")
            //                peripharal.writeValue(value, for: characteristic, type: .withResponse)
            //                requesting = true
            //            }
        case CBCharacteristicProperties.notify:
            print("Sucribed characteristics -- \(characteristic)")
            peripheral.setNotifyValue(true, for: characteristic)
        //            requesting = true
        default: break
        }
    }
    
    private func getTypeOfCahracteristic(characteristic : CBCharacteristic)-> CBCharacteristicProperties{
        if characteristic.properties.contains(.read) {
            return .read
        } else if characteristic.properties.contains(.write) {
            return .write
        }else if characteristic.properties.contains(.notify) {
            return .notify
        }
        return CBCharacteristicProperties()
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            let value = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            print("Characteristic value : \(value) with ID \(characteristic.uuid.uuidString)");
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
            print("Characteristic value : \(characteristic.value) with ID \(characteristic.uuid.uuidString)");
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic)
        }
    }

}
