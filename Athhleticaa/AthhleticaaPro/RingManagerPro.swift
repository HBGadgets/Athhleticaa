//
//  RingManagerPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 07/03/26.
//

import SwiftUI

final class RingManagerPro: NSObject, ObservableObject {

    static let shared = RingManagerPro()

    @Published var selectedTab: Int = 0
    @Published var errorMessage: String?
    @Published var selectedDayOffset: Int = 0
    @Published var selectedDate = Date()
    @Published var selectedTheme: AppTheme = .dark

    @Published var scannedDevices: [VPPeripheralModel] = []
    @Published var connectedPeripheral: CBPeripheral?
    private let lastDeviceKey = "last_connected_device"
    @Published var dataLoaded: Bool = false
    @Published private(set) var batteryLevel: Int?
    @Published var isCharging: Bool = false
    @Published var handRemovedFromElectrode: Bool = false
    @Published var ecgTestCompleted: Bool = false
    
    @Published var heartRateTestState: VPTestHeartState?
    @Published var heartRate: Int?
    @Published var vpttTestModel: VPPttValueModel?
    @Published var vpECGTestDataModel: VPECGTestDataModel?
    @Published var ecgTestProgress: Int?
    
    // MARK: Classes initialisation
    @Published var activityManager = ActivityManagerPro()
    @Published var heartRateManager = HeartRateManagerPro()
    @Published var bloodOxygenManager = BloodOxygenManagerPro()
    @Published var hrvManager = HrvManagerPro()
    @Published var detailDataManager = DetailDataManagerPro()
    @Published var sleepDataManager = SleepManagerPro()
    @Published var ecgManagerPro = ECGManagerPro()
    
    // MARK: Dashboard Variables
    @Published var dashboardStepsData: StepsDataString?
    @Published var dashboardHeartData: [HeartAndHealthData]? = []
    @Published var dashboardDetailsData: [RawHealthData]? = []
    @Published var dashboardSleepSegments: [SleepSegmentPro] = []
    @Published var dashboardSleepSummary: Summary?
    @Published var dashboardRawHealthDataStats: RawHealthDataStat?
    @Published var dashboardLatestValues: LatestHealthValues?
    
    //MARK: - interactive chart variables
    @Published var lastHapticDate: Date? = nil
    @Published var timeChartBloodOxygen: Date? = nil
    @Published var timeChartHeartRate: Date? = nil
    @Published var timeChartStress: Date? = nil
    @Published var timeChartHrv: Date? = nil
    @Published var timeChartSteps: Date? = nil
    @Published var timeChartDistance: Date? = nil
    @Published var timeChartCalories: Date? = nil
    
    @Published var spo2ValueChart: String? = nil
    @Published var heartRateValueChart: String? = nil
    @Published var stressValueChart: String? = nil
    @Published var hrvValueChart: String? = nil
    @Published var stepsValueChart: String? = nil
    @Published var distanceValueChart: String? = nil
    @Published var caloriesValueChart: String? = nil

    override init() {
        super.init()
        self.initSDK()
    }
    
    func callAllFunctions() {
        self.dataLoaded = false
        guard VPBleCentralManage.sharedBleManager().isConnected else {
            print("Device not connected")
            return
        }
        
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSdkStartReadDeviceAllData { (readDeviceBaseDataState, totalDay, currentReadDayNumber, readCurrentDayProgress) in
            switch readDeviceBaseDataState {
            case .start:
                print("Starting data sync")
            case .reading:
                let progressString = "\(currentReadDayNumber)/\(totalDay) - \(readCurrentDayProgress)%"
                print("Syncing: \(progressString)")
            case .complete:
                print("Data sync complete")
                DispatchQueue.main.async {
                    self.activityManager.readOneDayActivityData { data in
                        self.dashboardStepsData = data
                        self.dataLoaded = true
                    }
                    self.dataLoaded = true
                }
            default:
                break
            }
        }
    
    }
    
    func initSDK() {
        self.dataLoaded = false
        let manager = VPBleCentralManage.sharedBleManager()
        manager!.isLogEnable = true
        manager!.peripheralManage = VPPeripheralManage.shareVPPeripheralManager()
        
        manager!.vpBleCentralManageChangeBlock = { [weak self] state in
            switch state {
            case .poweredOn:
                print("Bluetooth powered on")
                self?.autoReconnectIfNeeded()
            case .poweredOff:
                print("Bluetooth is turned off")
            default:
                break
            }
        }
          
        // Add connection state monitoring
        manager!.vpBleConnectStateChangeBlock = { [weak self] connectState in
            switch connectState {
            case .connectStateConnect:
                // Connection established, peripheral should be available
                if let peripheral = manager!.peripheralModel.peripheral {
                    self?.onDeviceConnected(peripheral)
                }
            case .connectStateVerifyPasswordSuccess:
                print("Password verified - ready for operations")

                // Start battery monitoring AFTER verification
                self?.startBatteryMonitoring()
                self?.callAllFunctions()

                if let profile = UserProfileStorage.load() {
                    self?.syncUserProfileToDevice(profileArg: profile)
                } else {
                    print("couldn't load profile")
                }
            default:
                break
            }
        }
    }
    
    func disConnect() {
        let manager = VPBleCentralManage.sharedBleManager()
        manager?.veepooSDKDisconnectDevice()
        connectedPeripheral = nil
        // remove stored last-connected
        UserDefaults.standard.removeObject(forKey: lastDeviceKey)
    }
    
    func autoReconnectIfNeeded() {

        guard let lastAddress = UserDefaults.standard.string(forKey: lastDeviceKey) else {
            return
        }

        startScanning()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }

            if let device = self.scannedDevices.first(where: { $0.deviceAddress == lastAddress }) {
                print("Auto reconnecting to", lastAddress)
                self.connectDevice(device) { connected in
                    print("connect state:", connected)
                }
            }
        }
    }
    
    func startScanning() {

        print("BLE Scan Started")

        scannedDevices.removeAll()

        VPBleCentralManage.sharedBleManager()
            .veepooSDKStartScanDeviceAndReceiveScanningDevice { [weak self] peripheralModel in

                guard let device = peripheralModel else {
                    print("Received nil device")
                    return
                }

                print("Found:", device.deviceName, device.deviceAddress)

                self?.addDevice(device)
            }
    }
    
    private func addDevice(_ peripheralModel: VPPeripheralModel) {
        // Deduplicate by deviceAddress
        if !scannedDevices.contains(where: { $0.deviceAddress == peripheralModel.deviceAddress }) {
            DispatchQueue.main.async {
                self.scannedDevices.append(peripheralModel)
            }
        }
    }
    
    func connectDevice(_ peripheralModel: VPPeripheralModel,
                       completion: @escaping (DeviceConnectState) -> Void) {

        VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()

        VPBleCentralManage.sharedBleManager()
            .veepooSDKConnectDevice(peripheralModel) { [weak self] connectState in

                self?.handleConnectEvent(connectState: connectState)

                // ✅ forward EVERY state
                DispatchQueue.main.async {
                    completion(connectState)
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
    
    // MARK: - Device Connected Callback
    func onDeviceConnected(_ peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
        }

        // Save device address
        if let address = VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress {
            UserDefaults.standard.set(address, forKey: lastDeviceKey)
        }

        print("Device connected:", peripheral.name ?? "Unknown")
    }
    
    // MARK: - Sync Profile
    func syncUserProfileToDevice(profileArg: UserProfile) {
        print("sync user profile ran")

        let info = VPSyncPersonalInfo()

        info.status = Int32(profileArg.height)
        info.weight = Int32(profileArg.weight)
        info.age = Int32(profileArg.age)
        info.sex = Int32(profileArg.gender)
        info.targetStep = 10000
        info.targetSleepDuration = 8 * 60

        VPPeripheralManage.shareVPPeripheralManager()
            .veepooSDKSynchronousPersonalInformation(info) { result in
                print("got result of syncing personal information")
                if result == 1 {
                    print("✅ Personal info sync success")
                } else {
                    print("❌ Personal info sync failed:", result.words)
                }
            }
    }
    
    func startBatteryMonitoring() {
        VPPeripheralManage.shareVPPeripheralManager()
            .veepooSDKReadDeviceBatteryAndChargeInfo { [weak self] isPercent, chargeState, lowBat, battery in

                guard let self else { return }

                // Convert battery to percentage
                let percent: Int

                if isPercent {
                    percent = Int(battery)              // Already 0–100
                } else {
                    // Convert 0–4 bars → percentage
                    percent = Self.convertBatteryBarsToPercent(Int(battery))
                }

                // Map charge state
                let charging = Self.isChargingState(chargeState)

                DispatchQueue.main.async {
                    self.batteryLevel = percent
                    self.isCharging = charging
                }

                print("Battery level:", percent, "%")
                print("Charging:", charging)
            }
    }
    
    //MARK: Get data
    func waitForHeartData(day: Int, retries: Int = 5) {
        
        heartRateManager.readHeartRateDataByDay(day: day) { data in
            
            if let data, data.count > 5 {
                self.dashboardHeartData = data
                self.dataLoaded = true
            } else if retries > 0 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.waitForHeartData(day: day, retries: retries - 1)
                }
            }
        }
    }
    
    
    
    private static func isChargingState(_ state: VPDeviceChargeState) -> Bool {
        switch state {
        case .charging:
            return true
        default:
            return false
        }
    }
    
    private static func convertBatteryBarsToPercent(_ bars: Int) -> Int {
        switch bars {
        case 0: return 5
        case 1: return 25
        case 2: return 50
        case 3: return 75
        case 4: return 100
        default: return 0
        }
    }
}
