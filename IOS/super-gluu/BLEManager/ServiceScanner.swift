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
    
    var enrollResponseData: Data!
    
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
            
//            for characteristic in service.characteristics! {
//                let character = characteristic as CBCharacteristic
//                let type = getTypeOfCahracteristic(character)
//                if characteristic.uuid.uuidString == Constants.battery_uuid {
//                    self.doAction(prop: type, characteristic: characteristic)
//                }
//            }
            
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
        case CBCharacteristicProperties.write:
            if let value = valueForWrite {
                print("Trying to write for -- \(characteristic)")
                let dataArray = self.splitDataByPockets(data: value)
                //We should write value via pockets data by 20 bytes each frame (APDU)
                //now value has 64 bytes
                for data in dataArray {
//                    let valueToSend = self.makePocket(data: data)
                    print("---write pocket---")
                    self.peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }
            }
        case CBCharacteristicProperties.notify:
            print("Sucribed for u2fStatus characteristics -- \(characteristic)")
            self.peripheral.setNotifyValue(true, for: characteristic)
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
    
    func makePocket(data: Data)->Data{
        let bytes = data.toArray(type: UInt8.self)
        let enrollRequest : [UInt8] = bytes//[0x00, 0xCA, 0x00, 0x5A]//CLA INS(0x03) P1 P2(0x00) , 0x14Lc
        //data
//        enrollRequest.append(contentsOf: bytes)
        //response data lenght
//        enrollRequest.append(0x14)//Le
//        enrollRequest.append(0x00)//Le
//        let stringAgain = String.init(data: data, encoding: String.Encoding.utf8)
        let data = Data(bytes: enrollRequest);
//        print("data \(data) and stringAgain -- \(stringAgain)")
        
        return data
    }
    
    func splitDataByPockets(data: Data)->[Data]{
        var dataArray = [UInt8]()
//        let count = dataLength/20//should be 3 if length == 64
        //TODO should be rewrited for better solution
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
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: characteristic, userInfo: ["error": error])
        } else {
            let value = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            if characteristic.uuid.uuidString == Constants.u2fStatus_uuid {
                //We should split all response packets (34 by 20 bytes and last one 9 bytes)
                enrollResponseData.append(contentsOf: characteristic.value!)
                print("got response from F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB -- \(characteristic.value?.count)")
                if characteristic.value?.count == 9 {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.DidUpdateValueForCharacteristic), object: enrollResponseData)
                }
            } else {
                print("Characteristic value : \(UInt8(strtoul(value, nil, 16))) with ID \(characteristic.uuid.uuidString)");
            }
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
