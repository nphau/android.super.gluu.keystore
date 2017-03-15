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
    
    var valueForWrite: Data!
    
    func discoverCharacteristics(){
        characteristicObserver = CharacteristicObserver()
        for characteristic in service.characteristics! {
            let character = characteristic as CBCharacteristic
            let type = getTypeOfCahracteristic(character)
            if
//                characteristic.uuid.uuidString == Constants.FirmwareRevision ||
//                characteristic.uuid.uuidString == Constants.Battery ||
                characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid
//                    ||
//                characteristic.uuid.uuidString == Constants.u2fStatus_uuid ||
//                characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid
                {
                
                characteristicObserver.peripharal = peripharal
                characteristicObserver.characteristic = character
                characteristicObserver.valueForWrite = valueForWrite
                characteristicObserver.prop = type
                characteristicObserver.doAction()
            }
        }
        for characteristic in service.characteristics! {
            let character = characteristic as CBCharacteristic
            let type = getTypeOfCahracteristic(character)
            if
                //                characteristic.uuid.uuidString == Constants.FirmwareRevision ||
                //                characteristic.uuid.uuidString == Constants.Battery ||
//                characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid
                //                    ||
                                characteristic.uuid.uuidString == Constants.u2fStatus_uuid
//            ||
                //                characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid
            {
                
                characteristicObserver.peripharal = peripharal
                characteristicObserver.characteristic = character
                characteristicObserver.valueForWrite = valueForWrite
                characteristicObserver.prop = type
                characteristicObserver.doAction()
            }
        }
        for characteristic in service.characteristics! {
            let character = characteristic as CBCharacteristic
            let type = getTypeOfCahracteristic(character)
            if
                //                characteristic.uuid.uuidString == Constants.FirmwareRevision ||
                //                characteristic.uuid.uuidString == Constants.Battery ||
//                characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid
                //                    ||
                //                characteristic.uuid.uuidString == Constants.u2fStatus_uuid ||
                                characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid
            {
                
                characteristicObserver.peripharal = peripharal
                characteristicObserver.characteristic = character
                characteristicObserver.valueForWrite = valueForWrite
                characteristicObserver.prop = type
                characteristicObserver.doAction()
            }
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
    
}


class CharacteristicObserver: NSObject {
    
    var peripharal: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    var prop: CBCharacteristicProperties!
    
    var requesting = false
    
    var valueForWrite: Data!
    
    func doAction() {
        switch prop {
        case CBCharacteristicProperties.read:
            print("Trying to read value for -- \(characteristic)")
            peripharal.readValue(for: characteristic)
            requesting = true
        case CBCharacteristicProperties.write:
            if let value = valueForWrite {
                print("Trying to write for -- \(characteristic)")
                peripharal.writeValue(value, for: characteristic, type: .withResponse)
                requesting = true
            }
        case CBCharacteristicProperties.notify:
            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
            peripharal.setNotifyValue(true, for: characteristic)
            requesting = true
        default: break
        }
    }
    
}
