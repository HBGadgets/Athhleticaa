//
//  BloodOxygenManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 04/11/25.
//

import Foundation
import SwiftUI

enum BloodOxygenType: Int, Codable {
    case low = 0
    case normal
    case high

    var description: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }

    var color: Color {
        switch self {
        case .low: return .red
        case .normal: return .green
        case .high: return .orange
        }
    }
}

struct BloodOxygenModel: Identifiable, Codable {
    let id = UUID()
    var maxSoa2: Double
    var minSoa2: Double
    var soa2: Double
    var date: Date
    var soa2Type: BloodOxygenType
    var sourceType: Int
    var isSubmit: Bool
//    var device: String

    // Optional convenience init
    init(
        maxSoa2: Double,
        minSoa2: Double,
        soa2: Double,
        date: Date,
        soa2Type: BloodOxygenType,
        sourceType: Int,
        isSubmit: Bool,
//        device: String
    ) {
        self.maxSoa2 = maxSoa2
        self.minSoa2 = minSoa2
        self.soa2 = soa2
        self.date = date
        self.soa2Type = soa2Type
        self.sourceType = sourceType
        self.isSubmit = isSubmit
//        self.device = device
    }
}

//@MainActor
class BloodOxygenManager: ObservableObject {
    @Published var readings: [BloodOxygenModel] = []
    @Published var statusMessage: String = ""
    
    var lastNonZeroBloodOxygenValue: Double {
        readings.last(where: { $0.soa2 > 0 })?.soa2 ?? 0
    }
    
    /// All valid (non-zero) SpO₂ values
    var validBloodOxygenRates: [Double] {
        readings.map { $0.soa2 }.filter { $0 > 0 }
    }
    
    var validBloodOxygenModels: [BloodOxygenModel] {
        readings.filter { $0.soa2 > 0 }
    }

    /// Minimum SpO₂
    var minBloodOxygen: Double {
        validBloodOxygenRates.min() ?? 0
    }

    /// Maximum SpO₂
    var maxBloodOxygen: Double {
        validBloodOxygenRates.max() ?? 0
    }

    /// Average SpO₂
    var averageBloodOxygen: Double {
        guard !validBloodOxygenRates.isEmpty else { return 0 }
        let sum = validBloodOxygenRates.reduce(0, +)
        return sum / Double(validBloodOxygenRates.count)
    }
    
    var lastNonZeroBloodOxygenIndex: Int? {
        readings.firstIndex(where: { $0.soa2 > 0 })
    }
    
    /// The most recent non-zero blood oxygen model
    var lastNonZeroBloodOxygenReading: BloodOxygenModel? {
        readings.first(where: { $0.soa2 > 0 })
    }

    
    func fetchBloodOxygenData(dayIndex: Int = 0, completion: (() -> Void)? = nil) {
        QCSDKCmdCreator.getBloodOxygenData(byDayIndex: dayIndex) { data, error in
            if let error = error {
                print("❌ Failed to fetch blood oxygen data: \(error.localizedDescription)")
                self.statusMessage = "Fetch failed"
                completion?()
                return
            }

            guard let dataArray = data as? [QCBloodOxygenModel] else {
                print("⚠️ Unexpected data format")
                self.statusMessage = "Invalid data"
                completion?()
                return
            }

            // Map Objective-C objects to Swift model
            let mapped = dataArray.map { item in
                BloodOxygenModel(
                    maxSoa2: Double(item.maxSoa2),
                    minSoa2: Double(item.minSoa2),
                    soa2: Double(item.soa2),
                    date: item.date,
                    soa2Type: BloodOxygenType(rawValue: Int(item.soa2Type.rawValue)) ?? .normal,
                    sourceType: item.sourceType,
                    isSubmit: item.isSubmit,
//                    device: item.device
                )
            }

            self.readings = mapped.sorted(by: { $0.date > $1.date })
            self.statusMessage = "Fetched \(mapped.count) records"
            print("✅ Loaded \(mapped.count) blood oxygen entries")
            print(self.readings)
            completion?()
        }
    }
}
