//
//  PedometerManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 31/10/25.
//

import SwiftUI
import Charts


struct StepsData {
    let totalSteps: Int
    let calories: Double
    let distance: Int
}

class PedometerManager: ObservableObject {

    struct HourlyData: Identifiable {
        let id = UUID()
        let hour: Int   // 0–23
        let steps: Int
        let calories: Double
        let distance: Int
    }

    @Published var stepsData: StepsData?
    @Published var stepsDataDetails: StepsData?
    @Published var hourlyData: [HourlyData] = []
    @Published var hourlyDataSpecifiedDay: [HourlyData] = []
    
    func getPedometerData(completion: (() -> Void)? = nil) {
        print("🌟 Get pedometer data 🌟")
        QCSDKCmdCreator.getCurrentSportSucess({ sport in
            DispatchQueue.main.async {
                let data = StepsData(
                    totalSteps: sport.totalStepCount,
                    calories: sport.calories / 1000,
                    distance: sport.distance
                )
                self.stepsData = data
                
                let now = Date()
                let startOfDay = Calendar.current.startOfDay(for: now)
                
                completion?()
            }
        }, failed: {
            print("❌ Failed to get current sport summary")
            completion?()
        })
    }
    
    func getPedometerDataDetails(day: Int = 0, completion: (() -> Void)? = nil) {
        print("🌟 Get pedometer data 🌟")

        QCSDKCmdCreator.getSportDetailData(byDay: day, sportDatas: { sports in
            print("Get step count data details")
            
            var totalSteps = 0
            var caloriesDetails: Double = 0
            var distance = 0
            var hourly: [HourlyData] = []

            for model in sports {
                totalSteps += model.totalStepCount
                caloriesDetails += Double(Int(model.calories) / 1000)
                distance += model.distance

                // Parse the hour from "2025-11-08 09:00:00"
                if let dateString = model.happenDate,
                   let hourString = dateString.split(separator: " ").last?.prefix(2),
                   let hour = Int(hourString) {
                    hourly.append(
                        HourlyData(
                            hour: hour,
                            steps: model.totalStepCount,
                            calories: Double(Int(model.calories) / 1000),  // kcal
                            distance: model.distance
                        )
                    )
                }
                print("Pedometer data: \(model.happenDate ?? ""), steps: \(model.totalStepCount), calories: \(model.calories), distance: \(model.distance)")
            }
            
            print("Total Pedometer data: steps: \(totalSteps), calories: \(caloriesDetails), distance: \(distance)")
            
            DispatchQueue.main.async {
                self.stepsDataDetails = StepsData(
                    totalSteps: totalSteps,
                    calories: caloriesDetails, // convert to kcal
                    distance: distance
                )
                self.hourlyData = hourly
                completion?()
            }
            
        }, fail: {
            print("❌ Failed to get pedometer data")
            completion?()
        })
    }
}
