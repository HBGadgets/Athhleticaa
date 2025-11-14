//
//  HeartRateManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import Foundation
import Combine

import Foundation

// MARK: - Swift Model (Pure Swift)
struct HeartRateData: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let heartRates: [Int]
    let secondInterval: Int
    let serverID: Int
    let updateTime: Int
    let isSync: Bool
    let deviceID: String
    let deviceType: String
}

// MARK: - Converter from ObjC → Swift
extension Array where Element == QCSchedualHeartRateModel {
    func toSwiftModels() -> [HeartRateData] {
        self.map { objCModel in
            HeartRateData(
                date: objCModel.date ?? "",
                heartRates: objCModel.heartRates.map { $0.intValue },
                secondInterval: objCModel.secondInterval,
                serverID: objCModel.serverID,
                updateTime: objCModel.updateTime,
                isSync: objCModel.isSync,
                deviceID: objCModel.deviceID ?? "",
                deviceType: objCModel.deviceType ?? ""
            )
        }
    }
}

extension HeartRateData {
    var lastNonZeroHeartRate: Int {
        heartRates.last(where: { $0 != 0 }) ?? 0
    }
    
    var validHeartRates: [Int] {
        heartRates.filter { $0 > 0 }
    }

    var minHeartRate: Int {
        validHeartRates.min() ?? 0
    }

    var maxHeartRate: Int {
        validHeartRates.max() ?? 0
    }

    var averageHeartRate: Int {
        guard !validHeartRates.isEmpty else { return 0 }
        let sum = validHeartRates.reduce(0, +)
        return sum / validHeartRates.count
    }
    
    var lastNonZeroHeartRateIndex: Int? {
        heartRates.lastIndex(where: { $0 != 0 })
    }
}

extension HeartRateData {
    /// Returns a Date for a given heart rate index
    func timeForHeartRate(at index: Int) -> Date? {
        guard index >= 0 && index < heartRates.count else { return nil }
        
        // Combine the date string with 00:00:00 as start of day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let baseDate = formatter.date(from: date) else { return nil }
        
        // Offset in seconds = index * secondInterval
        let offsetSeconds = Double(index * secondInterval)
        return baseDate.addingTimeInterval(offsetSeconds)
    }
}

// MARK: - HeartRateManager
class HeartRateManager: ObservableObject {
    @Published var dayData: [HeartRateData] = []
    @Published var weekData: [HeartRateData] = []
    @Published var monthData: [HeartRateData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var heartRate: Int?

    enum DataType {
        case day
        case week
        case month
    }

    // MARK: - Fetch Data
    private func fetchHeartRateData(forDays days: [Int], type: DataType, completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil

        let dayIndexes = days.map { NSNumber(value: $0) }

        QCSDKCmdCreator.getSchedualHeartRateData(withDayIndexs: dayIndexes, success: { models in
            DispatchQueue.main.async {
                let parsed = models.toSwiftModels()
                
                switch type {
                case .day:
                    self.dayData = parsed
                    print("✅ Day data fetched:", parsed)
                case .week:
                    self.weekData = parsed
                    print("✅ Week data fetched:", parsed)
                case .month:
                    self.monthData = parsed
                    print("✅ Month data fetched:", parsed)
                }

                self.isLoading = false
                completion?()
            }
        }, fail: {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load heart rate data"
                self.isLoading = false
                print("❌ Failed to load data for \(type)")
                completion?()
            }
        })
    }
    
    func measureHeartRate(completion: (() -> Void)? = nil) {
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
                                completion?()
                            } else {
                                print("❌ Heart Rate measurement failed: \(error?.localizedDescription ?? "unknown error")")
                                completion?()
                            }
                        }
                    }
                )
            },
            failed: {
                print("❌ Failed to set time before Heart Rate measurement")
                completion?()
            }
        )
    }

    // MARK: - Public API
    func fetchTodayHeartRate(dayIndex: Int = 0, completion: (() -> Void)? = nil) {
        fetchHeartRateData(forDays: [dayIndex], type: .day) {
            completion?()
        }
    }

    func fetchWeeklyHeartRate() {
        let last7Days = Array(0..<7)
        fetchHeartRateData(forDays: last7Days, type: .week)
    }

    func fetchMonthlyHeartRate() {
        let last30Days = Array(0..<30)
        fetchHeartRateData(forDays: last30Days, type: .month)
    }
}
