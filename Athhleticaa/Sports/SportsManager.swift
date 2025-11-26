//
//  SportsManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

class SportsManager: ObservableObject {

    func startSport(type: OdmSportPlusExerciseModelType, completion: (() -> Void)? = nil) {
        QCSDKCmdCreator.operateSportMode(
            with: type,
            state: QCSportState.init(rawValue: 0x01),
        ) { response, error in
            if let error = error {
                print("❌ Failed: \(error.localizedDescription)")
                completion?()
            } else {
                print("✅ Sport mode started:", response ?? "nil")
                completion?()
            }
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
                print("✅ Sport mode paused:", response ?? "nil")
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
                print("✅ Sport mode continued:", response ?? "nil")
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
                print("✅ Sport mode stopped:", response ?? "nil")
            }
        }
    }
}
