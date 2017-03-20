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
                characteristic.uuid.uuidString == Constants.u2fControlPointLength_uuid ||
                characteristic.uuid.uuidString == Constants.u2fStatus_uuid ||
                characteristic.uuid.uuidString == Constants.u2fControlPoint_uuid {
                
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
    
    var valueForWrite: Data!
    
    func doAction() {
        switch prop {
        case CBCharacteristicProperties.read:
            print("Trying to read value for -- \(characteristic)")
            peripharal.readValue(for: characteristic)
        case CBCharacteristicProperties.write:
            if let value = valueForWrite {
                print("Trying to write for -- \(characteristic)")
                let dataArray = self.splitDataByPocketsForEnroll(data: value)
                //We should write value via pockets data by 20 bytes each frame (APDU)
                //now value has 64 bytes for enroll message
                for data in dataArray {
                    print("---write pocket---")
                    peripharal.writeValue(data, for: characteristic, type: .withResponse)
                }
            }
        case CBCharacteristicProperties.notify:
            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
            peripharal.setNotifyValue(true, for: characteristic)
        default: break
        }
    }
    
    func splitDataByPocketsForEnroll(data: Data)->[Data]{
        var dataArray = [UInt8]()
        for i in 0...3 {
            dataArray.append(contentsOf: makePoket(index: i, data: data))
        }
        var resultDataArray = [Data]()
        let endRange = 20
        for i in 0...3 {
            var range:Range<Int>!
            if i == 0 {
                range = i..<endRange //0..<20
            } else if i == 3 {
                range = i*endRange..<i*endRange + endRange - 1//60..<79
            }else {
                range = i*endRange..<i*endRange + endRange//20..<40
            }
            
            let dataAr = Data(bytes: dataArray)
            let pocket = dataAr.subdata(in: range)
            resultDataArray.append(pocket)
        }
        
        return resultDataArray
    }
    
    func makePoket(index:Int, data: Data)->[UInt8]{
        var firstParameter : [UInt8]!
        var range:Range<Int>!
        switch index {
        case 0:
            range = 0..<10
            firstParameter = [0x83, 0x00, 0x49, 0x00, 0x01, 0x03, 0x00, 0x00, 0x00, 0x40]
        case 1:
            range = 10..<29
            firstParameter = [UInt8(bitPattern: Int8(index-1))]
        case 2:
            range = 29..<48
            firstParameter = [0x01]
        case 3:
            range = 48..<64
            firstParameter = [0x02]
        default:
            print("none")
        }
        let pocket = data.subdata(in: range)
        if index == 3 {
            let endParameter : [UInt8] = [0x00, 0x00]
            firstParameter.append(contentsOf: pocket)
            firstParameter.append(contentsOf: endParameter)
        } else {
            firstParameter.append(contentsOf: pocket)
        }
        
        return firstParameter
    }
    
}
