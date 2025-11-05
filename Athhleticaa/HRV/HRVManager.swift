//
//  HRVManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 05/11/25.
//

import Foundation
import Combine

struct HRVModel: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let values: [Double]
    let interval: Int  // seconds between samples
}

@MainActor
class HRVManager: ObservableObject {
    @Published var hrvData: HRVModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    /// Fetch HRV data for a specific day (0 = today, 1 = yesterday, ..., 6 = 6 days ago)
    func fetchHRV(for day: Int, completion: (() -> Void)? = nil) {
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
                        values: model.hrv.map { $0.doubleValue },
                        interval: model.secondInterval
                    )
                    
                    print("✅ got data \(String(describing: self.hrvData))")
                    completion?()
                }
            }
        }
    }
}
