//
//  Classes.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 09/03/26.
//

class VPCustomScanManage: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
        
    static let sharedInstance = VPCustomScanManage()

    weak var manager: RingManagerPro?

    var centralManager: CBCentralManager?

    public func initDelegate() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func startScanDevices() {

        let service1 = CBUUID(string: "FFFF")
        let service2 = CBUUID(string: "FEE7")
        let service3 = CBUUID(string: "0001")
        let service4 = CBUUID(string: "180D")

        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]

        centralManager?.scanForPeripherals(
            withServices: [service1, service2, service3, service4],
            options: options
        )
    }
    
    public func connectFromSystem() -> Void {
        retrieveConnected()
    }
    
    public func disconnectDevice() -> Void {
        VPBleCentralManage.sharedBleManager().veepooSDKDisconnectDevice()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        guard RSSI.intValue >= -65 else { return }

        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String

        if let name, name == "itel ISW-42" {

            print("Found device:", name)

            connectDevice(peripheral: peripheral)
        }
    }
    
    public func connectDevice(peripheral: CBPeripheral) {

        centralManager?.stopScan()

        VPBleCentralManage.sharedBleManager()
            .veepooSDKSelfScanConnectDevice(peripheral) { [weak self] connectState in

                self?.handleConnectEvent(connectState: connectState)

                if connectState == .BleConnectSuccess {
                    self?.manager?.onDeviceConnected(peripheral)
                }
            }
    }
    
    func handleConnectEvent(connectState: DeviceConnectState) {

        switch connectState {

        case .BlePoweredOff:
            print("Bluetooth Off")

        case .BleConnecting:
            print("Connecting...")

        case .BleConnectSuccess:
            print("Connected")

        case .BleConnectFailed:
            print("Connect Failed")

        case .BleVerifyPasswordSuccess:
            print("Password Verified")

        case .BleVerifyPasswordFailure:
            print("Password Failed")

        case .BleConnectTimeout:
            print("Connection Timeout")
        }
    }
    
    /// 系统蓝牙状态监听
    /// - Parameter central: 中央管理器
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(">>centralManagerDidUpdateState")
    }
}

extension VPCustomScanManage {
    /// 获取系统蓝牙中已配对的外部设备
    public func retrieveConnected() {
        let serverStr = "F0020001-0451-4000-B000-000000000000"
        let peripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: serverStr)])
        
        guard let peripherals = peripherals else {
            return
        }
        
        if peripherals.count < 1 {
            return
        }
        
        // 直接连接第一个
        let peripheral = peripherals.first!
        
        connectDevice(peripheral: peripheral)
    }
}
