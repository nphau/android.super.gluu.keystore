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
    
    var valueForWrite: Data!
    
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
            //read characteristics
//            characteristicScanner = CharacteristicScanner()
//            characteristicScanner.peripharal = self.peripheral
//            characteristicScanner.service = service
//            characteristicScanner.valueForWrite = valueForWrite
//            characteristicScanner.discoverCharacteristics()
            
            for characteristic in service.characteristics! {
                let character = characteristic as CBCharacteristic
                let type = getTypeOfCahracteristic(character)
                if characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid {
                    self.doAction(prop: type, characteristic: characteristic)
                }
            }
            for characteristic in service.characteristics! {
                let character = characteristic as CBCharacteristic
                let type = getTypeOfCahracteristic(character)
                if characteristic.uuid.uuidString == Constants.u2fStatus_uuid {
                    self.doAction(prop: type, characteristic: characteristic)
                }
            }
            for characteristic in service.characteristics! {
                let character = characteristic as CBCharacteristic
                let type = getTypeOfCahracteristic(character)
                if characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid {
                    self.doAction(prop: type, characteristic: characteristic)
                }
            }
        }
    }
    
    func doAction(prop: CBCharacteristicProperties, characteristic: CBCharacteristic) {
        switch prop {
        case CBCharacteristicProperties.read:
            print("Trying to read value for -- \(characteristic)")
            self.peripheral.readValue(for: characteristic)
//            requesting = true
        case CBCharacteristicProperties.write:
            if let value = valueForWrite {
                print("Trying to write for -- \(characteristic)")
                self.peripheral.writeValue(value, for: characteristic, type: .withResponse)
//                requesting = true
            }
        case CBCharacteristicProperties.notify:
            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
            self.peripheral.setNotifyValue(true, for: characteristic)
//            requesting = true
        default: break
        }
    }
    
    fileprivate func getTypeOfCahracteristic(_ characteristic : CBCharacteristic)-> CBCharacteristicProperties{
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
            print("Characteristic value : \(value?.description) with ID \(characteristic.uuid.uuidString)");
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didWriteValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            print("Characteristic write value : \(characteristic.value) with ID \(characteristic.uuid.uuidString)");
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: characteristic.value)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateNotificationStateForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            print("Characteristic notification value : \(characteristic.value) with ID \(characteristic.uuid.uuidString)");
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: characteristic)
        }
    }

}
