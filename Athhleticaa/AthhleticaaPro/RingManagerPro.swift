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

    override init() {
        super.init()
        self.initSDK()
    }
    
    func callAllFunctions() {
        guard VPBleCentralManage.sharedBleManager().isConnected else {
            print("Device not connected")
            return
        }
          
        self.dataLoaded = false
          
        // Sync historical data from device
        VPBleCentralManage.sharedBleManager().peripheralManage
            .veepooSdkStartReadDeviceAllData { [weak self] readState, totalDay, currentDay, progress in
                switch readState {
                case .start:
                    print("Starting data sync")
                case .reading:
                    print("Syncing day \(currentDay)/\(totalDay) - \(progress)%")
                case .complete:
                    print("Data sync complete")
                    DispatchQueue.main.async {
                        self?.dataLoaded = true
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
    
    func autoReconnectIfNeeded() {

        guard let lastAddress = UserDefaults.standard.string(forKey: lastDeviceKey) else {
            return
        }

        startScanning()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }

            if let device = self.scannedDevices.first(where: { $0.deviceAddress == lastAddress }) {
                print("Auto reconnecting to", lastAddress)
                self.connectDevice(device)
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
    
    func connectDevice(_ peripheralModel: VPPeripheralModel) {
        VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()
          
        VPBleCentralManage.sharedBleManager()
            .veepooSDKConnectDevice(peripheralModel) { [weak self] connectState in
                self?.handleConnectEvent(connectState: connectState)
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
        self.dataLoaded = true
    }
}

struct WeeklyCalendarViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    var fromScreen: String
    @Environment(\.dismiss) private var dismiss


    // MARK: - Limit range: last 7 days including today
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)! // include today
        return sevenDaysAgo...today
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Date")
                .font(.headline)
                .padding(.top)

            // MARK: - Native DatePicker
            DatePicker(
                "Choose Date",
                selection: $ringManagerPro.selectedDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .accentColor(.orange)

            // MARK: - Confirm Button
            Button(action: {
                let dayOffset = calculateDayOffset(from: ringManagerPro.selectedDate)
                ringManagerPro.selectedDayOffset = dayOffset

                if fromScreen == "ActivityScreenPro" {
//                    ringManagerPro.pedometerManager.stepsDataDetails = nil
//                    ringManagerPro.pedometerManager.getPedometerDataDetails(day: dayOffset)
                    dismiss()
                } else if fromScreen == "HeartRateScreenPro" {
//                    ringManagerPro.heartRateManager.fetchTodayHeartRate(dayIndex: dayOffset)
                    dismiss()
                } else if fromScreen == "SleepAnalysisScreenPro" {
//                    ringManager.sleepManager.sleepSegments.removeAll()
//                    ringManager.sleepManager.getSleep(day: dayOffset)
                    dismiss()
                } else if fromScreen == "StressAnalysisScreenPro" {
//                    ringManager.stressManager.fetchStressData(day: dayOffset)
                    dismiss()
                } else if fromScreen == "BloodOxygenScreenPro" {
//                    ringManager.bloodOxygenManager.fetchBloodOxygenData(dayIndex: dayOffset)
                    dismiss()
                } else if fromScreen == "HRVScreenPro" {
//                    ringManager.hrvManager.fetchHRV(day: dayOffset)
                    dismiss()
                }
            }) {
                Text("Confirm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
//        .onAppear {
//            // Preselect currently selected offset or today if invalid
//            let calendar = Calendar.current
//            let today = calendar.startOfDay(for: Date())
//            let preselected = calendar.date(byAdding: .day, value: -ringManager.selectedDayOffset, to: today) ?? today
//            if dateRange.contains(preselected) {
//                ringManager.selectedDate = preselected
//            } else {
//                ringManager.selectedDate = today
//            }
//        }
    }

    // MARK: - Helper: Calculate offset between today and selected date
    private func calculateDayOffset(from date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: selected, to: today).day ?? 0
        return max(diff, 0)
    }
}
