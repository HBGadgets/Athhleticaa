//
//  StressManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore


struct StressModel: Identifiable, Codable {
    var id = UUID()
    let date: String              // "yyyy-MM-dd"
    let stresses: [Int]
    let secondInterval: Int       // Interval between data points (seconds)
    
    var average: Double {
        let validValues = stresses.filter { $0 > 0 }
        guard !validValues.isEmpty else { return 0 }
        return Double(validValues.reduce(0, +) / validValues.count)
    }
    
}

struct StressCategory: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}


extension StressModel {
    
    var categoryBreakdown: [StressCategory] {
        let values = validStress
        
        let low = values.filter { $0 < 29 }.count
        let normal = values.filter { $0 >= 30 && $0 <= 59 }.count
        let good = values.filter { $0 >= 60 && $0 <= 79 }.count
        let excellent = values.filter { $0 >= 80 && $0 <= 100 }.count
        
        return [
            StressCategory(name: "relax",       count: low,       color: .blue),
            StressCategory(name: "Normal",    count: normal,    color: .teal),
            StressCategory(name: "Medium",      count: good,      color: .yellow),
            StressCategory(name: "High", count: excellent, color: .red)
        ]
    }
    
    var relaxPercent: Int {
        let total = Double(stresses.count)
        let low = stresses.filter { $0 < 29 }.count
        let percent = (Double(low) / total) * 100
        return Int(percent)
    }
    
    var normalPercent: Int {
        let total = Double(stresses.count)
        let normal = stresses.filter { $0 >= 30 && $0 <= 59 }.count
        let percent = (Double(normal) / total) * 100
        return Int(percent)
    }
    
    var mediumPercent: Int {
        let total = Double(stresses.count)
        let high = stresses.filter { $0 >= 60 && $0 <= 79 }.count
        let percent = (Double(high) / total) * 100
        return Int(percent)
    }
    
    var highPercent: Int {
        let total = Double(stresses.count)
        let veryHigh = stresses.filter { $0 >= 80 && $0 <= 100 }.count
        let percent = (Double(veryHigh) / total) * 100
        return Int(percent)
    }
    
    var lastNonZeroStress: Int {
        stresses.last(where: { $0 != 0 }) ?? 0
    }
    
    var validStress: [Int] {
        stresses.filter { $0 > 0 }
    }

    var minStress: Int {
        validStress.min() ?? 0
    }

    var maxStress: Int {
        validStress.max() ?? 0
    }

    var averageStress: Int {
        guard !validStress.isEmpty else { return 0 }
        let sum = validStress.reduce(0, +)
        return sum / validStress.count
    }
    
    var lastNonZeroStressIndex: Int? {
        stresses.lastIndex(where: { $0 != 0 })
    }
    
    func timeForStressRate(at index: Int) -> Date? {
        guard index >= 0 && index < stresses.count else { return nil }
        
        // Combine the date string with 00:00:00 as start of day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let baseDate = formatter.date(from: date) else { return nil }
        
        // Offset in seconds = index * secondInterval
        let offsetSeconds = Double(index * secondInterval)
        return baseDate.addingTimeInterval(offsetSeconds)
    }
}


class StressManager: ObservableObject {

    @Published var stressData: [StressModel] = []
    @Published var validStressData: [StressModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var averageStress: Double = 0
    @Published var rangeMax: Int = 0
    @Published var rangeMin: Int = 0

    func fetchStressData(day: Int = 0, completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil

        QCSDKCmdCreator.getSchedualStressStatus { isOn, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription
                    self.isLoading = false
                }
                return
            }

            // ✅ Fetch only one specific day instead of all 7
            let days: [NSNumber] = [NSNumber(value: day)]

            QCSDKCmdCreator.getSchedualStressData(withDates: days) { models, err in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let err = err {
                        self.errorMessage = err.localizedDescription
                        completion?()
                        return
                    }

                    guard let models = models as? [QCStressModel], let model = models.first else {
                        self.errorMessage = "No stress data found for day \(day)"
                        completion?()
                        return
                    }

                    // ✅ Parse stress data for this specific day
                    let stressModel = StressModel(
                        date: model.date,
                        stresses: model.stresses.map { $0.intValue },
                        secondInterval: model.secondInterval
                    )
                    
                    let validStressModel = StressModel(
                        date: model.date,
                        stresses: self.stressData.first?.validStress ?? [0],
                        secondInterval: model.secondInterval
                    )

                    self.stressData = [stressModel]  // only one day's data
                    self.validStressData = [validStressModel]
                    
                    // ✅ Compute average and range
                    let nonZeroValues = stressModel.stresses.filter { $0 > 0 }
                    self.averageStress = stressModel.average
                    self.rangeMax = stressModel.stresses.max() ?? 0
                    self.rangeMin = nonZeroValues.min() ?? 0

                    print("✅ Stress data for day \(day):", stressModel)
                    completion?()
                }
            }
        }
    }
}
