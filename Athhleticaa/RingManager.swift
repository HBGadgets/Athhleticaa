//
//  RingManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/10/25.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUICore

@objcMembers
class SchedualHeartRateModel: NSObject, Identifiable {
    var timeString: String = ""
    var heartRate: Int = 0
}


/// SwiftUI-friendly replacement of the Objective-C QCCentralManager.
/// Not a singleton (you requested a normal class).
final class QCCentralManager: NSObject, ObservableObject {
    // MARK: - Published properties for SwiftUI
    @Published private(set) var peripherals: [QCBlePeripheral] = []
    @Published private(set) var connectedPeripheral: CBPeripheral?
    @Published private(set) var batteryLevel: Int?
    @Published var isCharging: Bool = false
    @Published var heartRate: Int?
    @Published var hrv: Int?
    @Published private(set) var deviceStateRaw: Int?   // Replace with SDK enum type if you have it
    @Published  var dataLoaded: Bool = false
    @Published private(set) var bleStateRaw: Int?
    @Published var currentHRV: Int = 0
    @Published var heartRateHistory: [SchedualHeartRateModel] = []
    @Published var errorMessage: String?
    @Published var selectedTab: Int = 0
    
    @Published var heartRateManager = HeartRateManager()
    @Published var pedometerManager = PedometerManager()
    @Published var stressManager = StressManager()
    @Published var sleepManager = SleepManager()
    @Published var bloodOxygenManager = BloodOxygenManager()
    @Published var hrvManager = HRVManager()
    @Published var selectedDayOffset: Int = 0
    @Published var selectedDate = Date()
    
    
    @Published var dashboardStepsData: StepsData?

    
    // MARK: - Private core bluetooth + sdk refs
    private var centralManager: CBCentralManager!
    private var sdkManager = QCSDKManager.shareInstance()
    
    // Strong references for peripherals being connected (to avoid API misuse)
    private var connectingPeripherals: [UUID: CBPeripheral] = [:]
    
    // Timers
    private var reconTimer: Timer?
    
    // Timeouts
    private var scanTimeout: TimeInterval = 15
    private var connectTimeout: TimeInterval = 6
    
    // Replace these constants with the SDK-provided strings (or ensure they are defined in your bridging header)
    private let serviceUUIDs: [CBUUID] = [
        CBUUID(string: QCBANDSDKSERVERUUID1),
        CBUUID(string: QCBANDSDKSERVERUUID2)
    ]
    
    // UserDefaults key
    private let lastConnectedKey = "QCLastConnectedIdentifier"
    
    // MARK: - Public init (normal class)
    override init() {
        super.init()
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBConnectPeripheralOptionNotifyOnConnectionKey: true
        ]
        centralManager = CBCentralManager(delegate: self, queue: .main, options: options)
        
        // 💡 Set up real-time battery monitoring
        QCSDKManager.shareInstance().currentBatteryInfo = { [weak self] battery, charging in
            DispatchQueue.main.async {
                self?.batteryLevel = Int(battery)
                self?.isCharging = charging
                print("🔋 Live battery update: \(battery)% — charging: \(charging)")
            }
        }
    }
    
    deinit {
        stopScan()
        stopTimer()
    }
    
    // MARK: - Public scan API
    func scan() {
        scan(withTimeout: Int(scanTimeout))
    }
    
    func scan(withTimeout timeout: Int) {
        scanTimeout = TimeInterval(max(0, timeout))
        stopScan()
        peripherals.removeAll()
        
        // If you prefer filtering by service UUIDs set serviceUUIDs instead of nil.
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        startScanTimeout()
        print("🔍 Scanning for peripherals (services: \(serviceUUIDs))")
        
        // Also include already-connected peripherals with SDK services (similar to ObjC demo)
        let connected = retrieveConnectedPeripherals(serviceUUIDs)
        var temp: [QCBlePeripheral] = []
        for p in connected {
            let qc = QCBlePeripheral(peripheral: p)
            qc.mac = "" // paired device may need queries to obtain mac
            qc.isPaired = true
            temp.append(qc)
        }
        if !temp.isEmpty {
            peripherals.append(contentsOf: temp)
            // UI update via @Published
        }
    }
    
    func stopScan() {
        guard centralManager != nil else { return }
        centralManager.stopScan()
        stopTimer()
    }
    
    // MARK: - Connect / Disconnect
    func connect(to peripheral: CBPeripheral, timeout: Int? = nil, completion: (() -> Void)? = nil) {
        if let t = timeout {
            connectTimeout = TimeInterval(max(0, t))
        }
        connectingPeripherals[peripheral.identifier] = peripheral
        // Keep a strong delegate reference on the peripheral if needed.
        centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
        startConnectTimeout(for: peripheral)
        completion?()
    }
    
    func disconnect() {
        if let device = connectedPeripheral {
            centralManager.cancelPeripheralConnection(device)
            sdkManager.remove(device)
            connectedPeripheral = nil
            // remove stored last-connected
            UserDefaults.standard.removeObject(forKey: lastConnectedKey)
        }
    }
    
    func removeAllBindings() {
        stopTimer()
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
        }
        QCSDKManager.shareInstance().removeAllPeripheral()
        UserDefaults.standard.removeObject(forKey: lastConnectedKey)
        deviceStateRaw = nil // maps to QCStateDisconnecting/unbound in ObjC
    }
    
    // MARK: - Reconnect and last peripheral helpers
    func startToReconnect() {
        // If Bluetooth is not poweredOn, report failure via UI or published state
        guard centralManager.state == .poweredOn else {
            // you can publish an error or handle it
            print("🔴 Bluetooth not powered on — cannot reconnect")
            return
        }
        guard let last = lastPeripheral() else {
            print("🔴 No last peripheral to reconnect")
            return
        }
        connect(to: last)
    }
    
    func lastPeripheral() -> CBPeripheral? {
        if let current = connectedPeripheral { return current }
        guard let uuidStr = UserDefaults.standard.string(forKey: lastConnectedKey), !uuidStr.isEmpty else {
            return nil
        }
        return peripheral(withUUID: uuidStr)
    }
    
    func isBindDevice() -> Bool {
        if let uuidStr = UserDefaults.standard.string(forKey: lastConnectedKey) {
            return !uuidStr.isEmpty
        }
        return false
    }
    
    // MARK: - SDK actions (battery / steps / measuring)
    func readBattery(completion: (() -> Void)? = nil) {
        QCSDKCmdCreator.readBatterySuccess({ [weak self] battery, charging in
            DispatchQueue.main.async {
                self?.batteryLevel = Int(battery)
                self?.isCharging = charging
                print("🔋 Battery level: \(battery), charging: \(charging)")
                completion?()
            }
        }, failed: {
            print("❌ Failed to read battery")
            completion?()
        })
    }
    
    func getSteps() {
        QCSDKCmdCreator.getSportDetailData(byDay: 0, sportDatas: { [weak self] sports in
            var totalStepCount = 0
            var totalCalories: Double = 0
            var totalDistance = 0
            for case let model as QCSportModel in sports {
                totalStepCount += Int(model.totalStepCount)
                totalCalories += model.calories
                totalDistance += Int(model.distance)
                print("Pedometer item: date:\(String(describing: model.happenDate)), steps:\(model.totalStepCount), calories:\(model.calories), distance:\(model.distance)")
            }
            DispatchQueue.main.async {
                // you can publish aggregated results or handle as needed
                print("Total steps: \(totalStepCount), calories: \(totalCalories), distance: \(totalDistance)")
            }
            
            QCSDKCmdCreator.getCurrentSportSucess({ sport in
                print("Current sport summary steps:\(sport.totalStepCount), calories:\(sport.calories), distance:\(sport.distance)")
            }, failed: {
                print("Failed to get current sport summary")
            })
            
        }, fail: {
            print("❌ getSportDetailData fail")
        })
    }
    
    func measureHeartRate() {
        print("🌟 Start Heart Rate measurement 🌟")
        
        QCSDKCmdCreator.setTime(Date(),
            success: { _ in
                // Use QCMeasuringTypeHR for heart rate
            let type = QCMeasuringType.heartRate
                
                QCSDKManager.shareInstance().startToMeasuring(
                    withOperateType: type,
                    measuringHandle: { result in
                        if let value = result as? NSNumber {
                            print("💓 Current Heart Rate: \(value.intValue) BPM")
                        }
                    },
                    completedHandle: { [weak self] success, result, error in
                        DispatchQueue.main.async {
                            if success, let hrValue = result as? NSNumber {
                                self?.heartRate = hrValue.intValue
                                print("✅ Heart Rate Measurement Complete: \(hrValue.intValue) BPM")
                            } else {
                                print("❌ Heart Rate measurement failed: \(error?.localizedDescription ?? "unknown error")")
                            }
                        }
                    }
                )
            },
            failed: {
                print("❌ Failed to set time before Heart Rate measurement")
            }
        )
    }

    // MARK: - Private helpers
    private func startScanTimeout() {
        stopTimer()
        reconTimer = Timer.scheduledTimer(timeInterval: scanTimeout, target: self, selector: #selector(stopScanFinishTimer(_:)), userInfo: nil, repeats: false)
        RunLoop.current.add(reconTimer!, forMode: .common)
    }
    
    private func startConnectTimeout(for peripheral: CBPeripheral) {
        stopTimer()
        reconTimer = Timer.scheduledTimer(withTimeInterval: connectTimeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.centralManager.cancelPeripheralConnection(peripheral)
            print("❌ Connection timeout for \(peripheral.name ?? "Unknown")")
            self.connectingPeripherals[peripheral.identifier] = nil
        }
        RunLoop.current.add(reconTimer!, forMode: .common)
    }
    
    @objc private func stopScanFinishTimer(_ timer: Timer) {
        stopScan()
    }
    
    private func stopTimer() {
        if let t = reconTimer, t.isValid {
            t.invalidate()
        }
        reconTimer = nil
    }
    
    private func peripheral(withUUID uuidString: String) -> CBPeripheral? {
        guard let uuid = UUID(uuidString: uuidString) else { return nil }
        let found = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        return found.first
    }
    
    private func retrieveConnectedPeripherals(_ uuids: [CBUUID]) -> [CBPeripheral] {
        let connected = centralManager.retrieveConnectedPeripherals(withServices: uuids)
        return connected
    }
}

// MARK: - CBCentralManagerDelegate
extension QCCentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManager state changed: \(central.state.rawValue)")
        self.bleStateRaw = central.state.rawValue
        // Map to device state if needed (this replicates ObjC behavior)
        if isBindDevice() {
            deviceStateRaw = 1 // connecting (replace with actual mapping)
        } else {
            deviceStateRaw = 0 // unbound (replace with actual mapping)
        }
        
        if central.state == .poweredOn {
            // If a previously stored peripheral exists and device state wants connecting, try reconnect
            if isBindDevice() {
                startToReconnect()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, !name.isEmpty else { return }
        
        // Search existing
        if let idx = peripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let existing = peripherals[idx]
            existing.peripheral = peripheral
            existing.mac = macFromAdvertisementData(advertisementData)
            existing.advertisementData = advertisementData
            existing.rssi = RSSI
            // early return replicates ObjC behavior
            return
        }
        
        let qc = QCBlePeripheral(peripheral: peripheral)
        qc.mac = macFromAdvertisementData(advertisementData)
        qc.advertisementData = advertisementData
        qc.rssi = RSSI
        peripherals.append(qc)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        connectingPeripherals[peripheral.identifier] = nil

        QCSDKManager.shareInstance().remove(peripheral)
        QCSDKManager.shareInstance().add(peripheral, finished: { [weak self] success in
            guard let self = self else { return }
            self.stopTimer()
            if success {
                UserDefaults.standard.setValue(peripheral.identifier.uuidString, forKey: self.lastConnectedKey)
                UserDefaults.standard.synchronize()
                self.deviceStateRaw = 2
                print("✅ Peripheral added successfully")

                // 💡 Add delay to let SDK fully initialize before fetching data
                DispatchQueue.main.async {
                    print("🚀 Device ready — starting data fetch")
                    self.heartRateManager.fetchTodayHeartRate() {
                        self.pedometerManager.getPedometerData() {
                            self.dashboardStepsData = self.pedometerManager.stepsData
                            self.stressManager.fetchStressData() {
                                self.sleepManager.getSleep() {
                                    self.readBattery() {
                                        self.bloodOxygenManager.fetchBloodOxygenData() {
                                            self.hrvManager.fetchHRV(for: 0) {
                                                if let firstTime = self.heartRateManager.dayData.first?.timeForHeartRate(at: self.heartRateManager.dayData.first?.lastNonZeroHeartRateIndex ?? 0
                                                ) {
                                                    let formatter = DateFormatter()
                                                    formatter.dateFormat = "h:mm a"
                                                    print("=============>>>>>First heart rate time:", formatter.string(from: firstTime))
                                                }
                                                self.dataLoaded = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            } else {
                print("❌ Failed to add peripheral")
            }
        })
    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected: \(peripheral.name ?? "Unknown") error: \(String(describing: error))")
        // If we explicitly removed/unbound, set unbound state, otherwise try reconnect flow
        // For simplicity, always attempt reconnect unless we were removing
        QCSDKManager.shareInstance().removeAllPeripheral()
        deviceStateRaw = 1 // connecting
        startToReconnect()
    }
    
    // If you enable restoration, implement willRestoreState here.
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        if let restored = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
//            for pr in restored {
//                if let lastUUID = UserDefaults.standard.string(forKey: lastConnectedKey),
//                   lastUUID == pr.identifier.uuidString {
//                    connectedPeripheral = pr
//                    break
//                }
//            }
//        }
//    }
}

// MARK: - Advertisement helpers (mac extraction)
private extension QCCentralManager {
    func macFromAdvertisementData(_ advertisementData: [String: Any]) -> String {
        if let manufacturer = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            let mac = macFromData(manufacturer)
            if !mac.isEmpty { return mac }
        }
        if let serviceData = advertisementData["kCBAdvDataServiceData"] as? [String: Any] {
            for value in serviceData.values {
                if let data = value as? Data {
                    let mac = macFromData(data)
                    if !mac.isEmpty { return mac }
                }
            }
        }
        return ""
    }
    
    func macFromData(_ macData: Data?) -> String {
        guard let macData = macData, macData.count > 0 else { return "" }
        var data = macData
        if data.count >= 10 {
            data = data.subdata(in: 4..<10)
        } else if data.count == 8 {
            data = data.subdata(in: 2..<8)
        } else if data.count == 6 {
            // keep as-is
        } else {
            return ""
        }
        let bytes = [UInt8](data)
        return bytes.map { String(format: "%02x", $0) }.joined(separator: ":")
    }
}

import SwiftUI

struct WeeklyCalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
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
                selection: $ringManager.selectedDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .accentColor(.orange)

            // MARK: - Confirm Button
            Button(action: {
                let dayOffset = calculateDayOffset(from: ringManager.selectedDate)
                ringManager.selectedDayOffset = dayOffset

                if fromScreen == "ActivityScreen" {
                    ringManager.pedometerManager.stepsDataDetails = nil
                    ringManager.pedometerManager.getPedometerDataDetails(day: dayOffset)
                    dismiss()
                } else if fromScreen == "HeartRateScreen" {
                    ringManager.heartRateManager.fetchTodayHeartRate(dayIndex: dayOffset)
                    dismiss()
                } else if fromScreen == "SleepAnalysisScreen" {
                    ringManager.sleepManager.sleepSegments.removeAll()
                    ringManager.sleepManager.getSleep(day: dayOffset)
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
        .onAppear {
            // Preselect currently selected offset or today if invalid
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let preselected = calendar.date(byAdding: .day, value: -ringManager.selectedDayOffset, to: today) ?? today
            if dateRange.contains(preselected) {
                ringManager.selectedDate = preselected
            } else {
                ringManager.selectedDate = today
            }
        }
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
