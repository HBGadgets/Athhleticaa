//
//  QCBlePeripheral.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 25/10/25.
//

import Foundation
import CoreBluetooth

/// Wrapper around CBPeripheral to carry extra metadata (mac, RSSI, advertisementData)
final class QCBlePeripheral: Identifiable {
    let id: UUID
    var peripheral: CBPeripheral
    var mac: String = ""
    var rssi: NSNumber?
    var advertisementData: [String: Any]?
    var isPaired: Bool = false
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.id = peripheral.identifier
    }
}
