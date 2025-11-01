//
//  StressManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//


struct StressModel: Identifiable, Codable {
    var id = UUID()
    let date: String              // "yyyy-MM-dd"
    let stresses: [Int]        // Stress values array
    let secondInterval: Int       // Interval between data points (seconds)
    
    var average: Double {
        let validValues = stresses.filter { $0 > 0 }
        guard !validValues.isEmpty else { return 0 }
        return Double(validValues.reduce(0, +) / validValues.count)
    }
    
}

class StressManager: ObservableObject {

    @Published var stressData: [StressModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var averageStress: Double = 0
    @Published var rangeMax: Int = 0
    @Published var rangeMin: Int = 0

    func fetchStressData(completion: (() -> Void)? = nil) {
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

            let days: [NSNumber] = [0, 1, 2, 3, 4, 5, 6].map { NSNumber(value: $0) }
            QCSDKCmdCreator.getSchedualStressData(withDates: days) { models, err in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let err = err {
                        self.errorMessage = err.localizedDescription
                        completion?()
                        return
                    }

                    guard let models = models as? [QCStressModel] else {
                        self.errorMessage = "Failed to parse stress data"
                        completion?()
                        return
                    }

                    self.stressData = models.map { model in
                        StressModel(
                            date: model.date,
                            stresses: model.stresses.map { $0.intValue },
                            secondInterval: model.secondInterval
                        )
                    }
                    
                    // ✅ Get today’s average (latest date)
                    if let today = self.stressData.last {
                        let nonZeroValues = today.stresses.filter { $0 > 0 }

                        self.averageStress = today.average
                        self.rangeMax = self.stressData.first?.stresses.max() ?? 0
                        self.rangeMin = nonZeroValues.min() ?? 0
                    }
                    
                    print("✅ Stress data fetched:", self.stressData)
                    completion?()
                }
            }
        }
    }
}

extension StressModel {
    var lastNonZeroStress: Int {
        stresses.last(where: { $0 != 0 }) ?? 0
    }
}
