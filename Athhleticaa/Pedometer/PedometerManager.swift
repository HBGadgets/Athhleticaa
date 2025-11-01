//
//  PedometerManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 31/10/25.
//

class PedometerManager: ObservableObject {
    struct StepsData {
        let totalSteps: Int
        let calories: Double
        let distance: Int
    }

    @Published var stepsData: StepsData?

    func getPedometerData(completion: (() -> Void)? = nil) {
        print("🌟 Get pedometer data 🌟")

        QCSDKCmdCreator.getSportDetailData(byDay: 0, sportDatas: { sports in
            print("Get step count data details")
            
            var totalSteps = 0
            var calories: Double = 0
            var distance = 0
            
            for model in sports {
                totalSteps += model.totalStepCount
                calories += model.calories
                distance += model.distance
                
                print("Pedometer data: \(model.happenDate ?? ""), steps: \(model.totalStepCount), calories: \(model.calories), distance: \(model.distance)")
            }
            
            QCSDKCmdCreator.getCurrentSportSucess({ sport in
                DispatchQueue.main.async {
                    self.stepsData = StepsData(
                        totalSteps: sport.totalStepCount,
                        calories: sport.calories,
                        distance: sport.distance
                    )
                    completion?()
                }
            }, failed: {
                print("❌ Failed to get current sport summary")
                completion?()
            })
            
        }, fail: {
            print("❌ Failed to get pedometer data")
            completion?()
        })
    }
}
