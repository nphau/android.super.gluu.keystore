//
//  PeripheralScanner.swift
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/9/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Constants {
//    static let PeripheralCell = "PeripheralCell"
//    static let ServiceCell = "ServiceCell"
//    static let CharacteristicCell = "CharacteristicCell"
//    static let CharacteristicAccessCell = "CharacteristicAccessCell"
//    static let SwitcherCell = "SwitcherCell"
//    static let ScanUUIDCell = "ScanUUIDCell"
//    static let FindedPeripheralCell = "FindedPeripheralCell"
    
    static let ConnectTimeout: TimeInterval = 5
    static let DidUpdateValueForCharacteristic = "didUpdateValueForCharacteristic"
    static let DidWriteValueForCharacteristic = "didWriteValueForCharacteristic"
    static let DidUpdateNotificationStateForCharacteristic = "didUpdateNotificationStateForCharacteristic"
}

class PeripheralScanner : NSObject, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    
    var peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
    
    var connectTimer: Timer?
    
    var scanning = false {
        didSet {
//            title = scanning ? "Scanning..." : "Peripherals"
//            scanStopButtonItem.title = scanning ? "Stop" : "Scan"
            
            if scanning {
                //				let uuid1 = CBUUID(string: "180A")
                //				let uuid2 = CBUUID(string: "180D")
                //				centralManager.scanForPeripheralsWithServices([uuid1, uuid2], options: nil)
                
                //Vasco u2f token device's UUID
                //                let uuid = CBUUID(string: "8610C427-C32E-4AEB-A086-D6ACF31BCF24")
                //				centralManager.scanForPeripherals(withServices: [uuid], options: nil)
                
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                NSLog("scanning...")
            } else {
                centralManager.stopScan()
                cancelConnections()
                NSLog("scanning stopped.")
            }
        }
    }
    
//    @IBAction func clear(_ sender: AnyObject) {
//        peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
//        tableView.reloadData()
//        if scanning {
//            scanning = false
//            scanning = true
//        }
//    }
    
//    @IBOutlet weak var scanStopButtonItem: UIBarButtonItem!
//    func scanStop() {
//        scanning = !scanning
//    }
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func cancelConnections() {
        print("cancelConnections")
        for peripheralCouple in peripherals {
            //			if peripheralCouple.peripheral.state == .Connected
            //				|| peripheralCouple.peripheral.state == .Connecting {
            centralManager.cancelPeripheralConnection(peripheralCouple.peripheral)
            //			}
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        tableView.rowHeight = UITableViewAutomaticDimension
////        tableView.estimatedRowHeight = 60
//        
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        cancelConnections()
//    }
    
    // MARK: - Central Manager Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(centralManager.state)
        if centralManager.state != .poweredOn {
            //            _=navigationController?.popToViewController(self, animated: true)
            if scanning {
                UIAlertView(title: "Unable to scan", message: "bluetooth is in \(centralManager.state.rawValue)-state", delegate: nil, cancelButtonTitle: "Ok").show()
            }
            //            tableView.reloadData()
        }
        scanning = centralManager.state == .poweredOn
        //        scanStopButtonItem.isEnabled = centralManager.state == .poweredOn
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("discovered \(peripheral.name ?? "Noname") RSSI: \(RSSI)\n\(advertisementData)")
        
        let contains = peripherals.contains { (peripheralInner: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?) -> Bool in
            return peripheral == peripheralInner
        }
        
        if peripheral.name != "SClick U2F" {
            return
        }
        
        if !contains {
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                let UUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as! [CBUUID]
                peripherals.append((peripheral, serviceUUIDs.count, UUIDs))
            } else {
                peripherals.append((peripheral, 0, nil))
            }
        }
        //        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("didConnectPeripheral \(peripheral.name)")
        //        tableView.reloadData()
        
        connectTimer?.invalidate()
        
        //        if let serviceTableVC = navigationController?.topViewController as? ServiceTableVC {
        //            peripheral.delegate = serviceTableVC
        //        }
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("didDisconnectPeripheral \(peripheral.name)")
        //        tableView.reloadData()
        //        _=navigationController?.popToViewController(self, animated: true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("\tdidFailToConnectPeripheral \(peripheral.name)")
        //        tableView.reloadData()
        //        _=navigationController?.popToViewController(self, animated: true)
        UIAlertView(title: "Fail To Connect", message: nil, delegate: nil, cancelButtonTitle: "Dismiss").show()
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        NSLog("willRestoreState \(dict)")
    }

    
}


//extension PeripheralScanner : CBCentralManagerDelegate{
//
//    
//}
