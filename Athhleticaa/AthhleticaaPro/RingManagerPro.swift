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
    @Published private(set) var connectedPeripheral: CBPeripheral?
    @Published var errorMessage: String?
    @Published var selectedDayOffset: Int = 0
    @Published var selectedDate = Date()
    @Published var selectedTheme: AppTheme = .dark
    

    override init() {
        super.init()
    }
    
    func callAllFunctions() {
        
    }
    
    // MARK: - Start Custom Scan
    func startScanning() {
        VPCustomScanManage.sharedInstance.manager = self
        VPCustomScanManage.sharedInstance.initDelegate()
        VPCustomScanManage.sharedInstance.startScanDevices()
        print("Started scanning...")
    }
    
    // MARK: - Device Connected Callback
    func onDeviceConnected(_ peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
        }

        print("Device connected:", peripheral.name ?? "Unknown")

        let profile = UserProfileStorage.load()
        if let profile {
            syncUserProfileToDevice(profileArg: profile)
        }
    }
    
    // MARK: - Sync Profile
    func syncUserProfileToDevice(profileArg: UserProfile) {

        let info = VPSyncPersonalInfo()

        info.status = Int32(profileArg.height)
        info.weight = Int32(profileArg.weight)
        info.age = Int32(profileArg.age)
        info.sex = Int32(profileArg.gender)
        info.targetStep = 10000
        info.targetSleepDuration = 8 * 60

        VPPeripheralManage.shareVPPeripheralManager()
            .veepooSDKSynchronousPersonalInformation(info) { result in

                if result == 0 {
                    print("✅ Personal info sync success")
                } else {
                    print("❌ Personal info sync failed:", result)
                }
            }
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
