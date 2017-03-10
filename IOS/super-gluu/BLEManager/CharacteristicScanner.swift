//
//  CharacteristicScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/10/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicScanner: NSObject {
    
    var peripharal: CBPeripheral!
    var service: CBService!
    
    var characteristicObserver : CharacteristicObserver!
    
    func discoverCharacteristics(){
        characteristicObserver = CharacteristicObserver()
        for characteristic in service.characteristics! {
            let character = characteristic as CBCharacteristic
            let type = getTypeOfCahracteristic(characteristic: character)
            //Currectly we want do only write action for u2fControlPoint characteristic
//            print("character.uuid.uuidString -- \(character.uuid.uuidString)")
//            if character.uuid.uuidString == Constants.u2fControlPoint_uuid || character.uuid.uuidString == Constants.battery_uuid {
                characteristicObserver.peripharal = peripharal
                characteristicObserver.characteristic = character
                characteristicObserver.prop = type
                characteristicObserver.doAction()
//            }
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
    
}


class CharacteristicObserver: NSObject {
    
    var peripharal: CBPeripheral!
    var characteristic: CBCharacteristic! {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(CharacteristicObserver.didUpdateValueForCharacteristic(_:)), name: NSNotification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CharacteristicObserver.didWriteValueForCharacteristic(_:)), name: NSNotification.Name(rawValue: Constants.DidWriteValueForCharacteristic), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CharacteristicObserver.didUpdateNotificationStateForCharacteristic(_:)), name: NSNotification.Name(rawValue: Constants.DidUpdateNotificationStateForCharacteristic), object: nil)
        }
    }
    
    var prop: CBCharacteristicProperties!
    
    var requesting = false
    
    func doAction() {
        switch prop {
        case CBCharacteristicProperties.read:
            print("Trying to read avlue for -- \(characteristic)")
            peripharal.readValue(for: characteristic)
            requesting = true
//        case CBCharacteristicProperties.write:
//            if let value = "000000".data(using: String.Encoding.utf8) {
//                print("Trying to write password for pairing maybe -- \(characteristic)")
//                peripharal.writeValue(value, for: characteristic, type: .withResponse)
//                requesting = true
//            }
//        case CBCharacteristicProperties.notify:
//            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
//            peripharal.setNotifyValue(true, for: characteristic)
//            requesting = true
        default: break
        }
    }

    // MARK: observing
    
    func didUpdateValueForCharacteristic(_ notification: Notification) {
        guard requesting else { return }
        requesting = prop == .notify ? requesting : false
        guard let characteristic = notification.object as? CBCharacteristic else { return }
        guard characteristic.uuid.isEqual(self.characteristic.uuid) else { return }
        if let error = notification.userInfo?["error"] as? NSError {
            print("error.localizedDescription --- \(error.localizedDescription)")
        } else {
            if let value = characteristic.value {
                print("value --- \(String(data: value, encoding: String.Encoding.utf8))")
            } else {
//                valueTextField.text = nil
            }
            print("no value")
        }
    }
    
    func didWriteValueForCharacteristic(_ notification: Notification) {
        guard requesting else { return }
        requesting = false
        guard let characteristic = notification.object as? CBCharacteristic else { return }
        guard characteristic.uuid.isEqual(self.characteristic.uuid) else { return }
        if let error = notification.userInfo?["error"] as? NSError {
            print("error.localizedDescription --- \(error.localizedDescription)")
        } else {
            NSLog("ok \(characteristic.value)")
        }
    }
    
    func didUpdateNotificationStateForCharacteristic(_ notification: Notification) {
        guard requesting else { return }
        guard let characteristic = notification.object as? CBCharacteristic else { return }
        guard characteristic.uuid.isEqual(self.characteristic.uuid) else { return }
        if let error = notification.userInfo?["error"] as? NSError {
            print("error.localizedDescription --- \(error.localizedDescription)")
        } else {
            if let value = characteristic.value {
                print("value --- \(String(data: value, encoding: String.Encoding.utf8))")
            } else {
//                valueTextField.text = nil
            }
            print("no value")
        }
    }
    
}
