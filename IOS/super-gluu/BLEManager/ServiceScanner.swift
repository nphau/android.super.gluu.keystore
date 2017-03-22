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
    
    var valueForWrite: Data!//Data for write to device
    var enrollResponseData: Data!//Data received from device
    var isPairing: Bool!
    var isEnroll: Bool!
    
//    let scanner = BackgroundScanner.defaultScanner
    
    override init() {
        super.init()
        enrollResponseData = Data.init()
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
            characteristicScanner = CharacteristicScanner()
            characteristicScanner.peripharal = self.peripheral
            characteristicScanner.service = service
            characteristicScanner.valueForWrite = valueForWrite
            characteristicScanner.discoverCharacteristics(isPairing: isPairing)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            handleResult(characteristic: characteristic)
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
    
    func handleResult(characteristic: CBCharacteristic){
        let value = String(data: characteristic.value!, encoding: String.Encoding.utf8)
        if characteristic.uuid.uuidString == Constants.u2fStatus_uuid {
            //We should split all response packets (34 by 20 bytes and last one 9 bytes)
            enrollResponseData.append(contentsOf: characteristic.value!)
            print("got response from F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB -- \(characteristic.value?.count)")
            if (characteristic.value?.count)! <= 10 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: ["responseData" : enrollResponseData,
                                                                "isEnroll" : isEnroll])
            }
        } else {
            print("Characteristic value : \(UInt8(strtoul(value, nil, 16))) with ID \(characteristic.uuid.uuidString)");
        }
    }

}
