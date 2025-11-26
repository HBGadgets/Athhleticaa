//
//  SportsManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

class SportsManager: ObservableObject {
//    let sportType: OdmSportPlusExerciseModelType = .gpsBike

    func startSport(type: OdmSportPlusExerciseModelType) {
        QCSDKCmdCreator.operateSportMode(
            with: type,
            state: QCSportState.init(rawValue: 0x01),
        ) { response, error in
            if let error = error {
                print("❌ Failed: \(error.localizedDescription)")
            } else {
                print("✅ Sport mode started:", response ?? "nil")
            }
        }
        
        QCSDKManager.shareInstance().currentSportInfo = { info in
            print("---- SPORT LIVE INFO ----")
            print("Type:", info.sportType)
            print("State:", info.state)
            print("Duration:", info.duration)
            print("HR:", info.hr)
            print("Steps:", info.step)
            print("Calorie:", info.calorie)
            print("Distance:", info.distance)
            print("-------------------------")
        }
    }

    func pauseSport(type: OdmSportPlusExerciseModelType) {
        QCSDKCmdCreator.operateSportMode(
            with: type,
            state: QCSportState.init(rawValue: 0x02),
        ) { response, error in
            if let error = error {
                print("❌ Failed: \(error.localizedDescription)")
            } else {
                print("✅ Sport mode started:", response ?? "nil")
            }
        }
    }
    
    func continueSport(type: OdmSportPlusExerciseModelType) {
        QCSDKCmdCreator.operateSportMode(
            with: type,
            state: QCSportState.init(rawValue: 0x03),
        ) { response, error in
            if let error = error {
                print("❌ Failed: \(error.localizedDescription)")
            } else {
                print("✅ Sport mode started:", response ?? "nil")
            }
        }
    }

    func stopSport(type: OdmSportPlusExerciseModelType) {
        QCSDKCmdCreator.operateSportMode(
            with: type,
            state: QCSportState.init(rawValue: 0x04),
        ) { response, error in
            if let error = error {
                print("❌ Failed: \(error.localizedDescription)")
            } else {
                print("✅ Sport mode started:", response ?? "nil")
            }
        }
    }
}
