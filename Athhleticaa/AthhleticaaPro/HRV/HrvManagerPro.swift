//
//  HrvManagerPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 16/03/26.
//

class HrvManagerPro: ObservableObject {
    
    
    func readHrvData(completion: @escaping (Bool?) -> Void) {

    VPBleCentralManage.sharedBleManager().peripheralManage.veepooSdkStartReadDeviceHrvData {[weak self] (readDeviceBaseDataState, totalDay, currentReadDayNumber, readCurrentDayProgress) in
        switch readDeviceBaseDataState {
        case .start:
            print("started reading hrv data")
        case .reading:
            let progressString: String = String(currentReadDayNumber) + "/" + String(totalDay) + "  " + String(readCurrentDayProgress) + "%"
            print(progressString)
        case .complete:
            return completion(true)
        default:
            break
            }
        }
    }
}
