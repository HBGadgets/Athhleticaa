//
//  HRVManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 05/11/25.
//

import Foundation
import Combine
import SwiftUICore

struct HRVModel: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let values: [Int]
    let interval: Int  // seconds between samples
}

struct HRVCategory: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}

extension HRVModel {
    
    var lastNonZeroHRV: Int {
        values.last(where: { $0 != 0 }) ?? 0
    }
    
    var validHRV: [Int] {
        values.filter { $0 > 0 }
    }

    var minHRV: Int {
        validHRV.min() ?? 0
    }

    var maxHRV: Int {
        validHRV.max() ?? 0
    }

    var averageHRV: Int {
        guard !validHRV.isEmpty else { return 0 }
        let sum = validHRV.reduce(0, +)
        return sum / validHRV.count
    }
    
    var lastNonZeroHRVIndex: Int? {
        values.lastIndex(where: { $0 != 0 })
    }
    
    func timeForHRVRate(at index: Int) -> Date? {
        guard index >= 0 && index < values.count else { return nil }
        
        // Combine the date string with 00:00:00 as start of day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let baseDate = formatter.date(from: date) else { return nil }
        
        // Offset in seconds = index * secondInterval
        let offsetSeconds = Double(index * interval)
        return baseDate.addingTimeInterval(offsetSeconds)
    }
    
    var categoryBreakdown: [HRVCategory] {
        let values = validHRV
        
        let low = values.filter { $0 < 31 }.count
        let normal = values.filter { $0 >= 31 && $0 <= 60 }.count
        let good = values.filter { $0 >= 61 && $0 <= 101 }.count
        let excellent = values.filter { $0 > 101 }.count
        
        return [
            HRVCategory(name: "Low",       count: low,       color: .red),
            HRVCategory(name: "Normal",    count: normal,    color: .yellow),
            HRVCategory(name: "Good",      count: good,      color: .green),
            HRVCategory(name: "Excellent", count: excellent, color: .blue)
        ]
    }
}


//@MainActor
class HRVManager: ObservableObject {
    @Published var hrvData: HRVModel?
    @Published var validHrvData: HRVModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    /// Fetch HRV data for a specific day (0 = today, 1 = yesterday, ..., 6 = 6 days ago)
    func fetchHRV(day: Int = 0, completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil
        
        QCSDKCmdCreator.getSchedualHRV { isOn, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "❌Failed to get HRV schedule status: \(error.localizedDescription)"
                    self.isLoading = false
                }
                completion?()
                return
            }
            
            guard isOn else {
                DispatchQueue.main.async {
                    self.errorMessage = "❌HRV Schedule is OFF"
                    self.isLoading = false
                }
                completion?()
                return
            }
            
            // Fetch HRV data for the specific day
            QCSDKCmdCreator.getSchedualHRVData(withDates: [NSNumber(value: day)]) { models, err in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let err = err {
                        self.errorMessage = "❌Error fetching HRV data: \(err.localizedDescription)"
                        completion?()
                        return
                    }
                    
                    guard let models = models as? [QCHRVModel], let model = models.first else {
                        self.errorMessage = "❌No HRV data found for day \(day)"
                        completion?()
                        return
                    }
                    
                    self.hrvData = HRVModel(
                        date: model.date,
                        values: model.hrv.map { $0.intValue },
                        interval: model.secondInterval
                    )
                    
                    self.validHrvData = HRVModel(
                        date: model.date,
                        values: self.hrvData?.validHRV ?? [0],
                        interval: model.secondInterval
                    )
                    
                    print("✅ got data \(String(describing: self.hrvData))")
                    completion?()
                }
            }
        }
    }
}
