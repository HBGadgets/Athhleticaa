//
//  ECGManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/03/26.
//

class ECGManagerPro: ObservableObject {
    
    
    func startECGTest() {
        
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestECGStart(true) { testECGState, testProgress, testModel in
            switch testECGState {
            case .start:
                print("ECG test starting")
            case .testing:
                print("ECG testing, progress: \(testProgress)%")
                print("average hrv: \(testModel?.aveHrv)")
                print("average heartRate: \(testModel?.aveHrv)")
            case .complete:
                print("ECG test completed")
                // Process testModel for ECG data
                print("ecg data ===>>> \(testModel?.ecgType)")
            case .noFunction:
                print("Device does not support ECG")
            default:
                break
            }
        }
        
    }
    
    func getECGHistory(day: Int) {
        print("get ecg history function ran")
        
        let ecgType = VPBleCentralManage.sharedBleManager().peripheralManage.peripheralModel.ecgType
        
        print("ecg type ====>>> \(ecgType)")
        
        if ecgType == 1 || ecgType == 2 {
            // Device supports basic ECG - use veepooSDKTestECGStart
            print("Basic ECG supported")
        } else if ecgType == 7 {
            // Device supports multi-lead ECG
            print("Multi-lead ECG supported")
        } else {
            print("ECG type ====>> \(ecgType)")
        }
        
        
        let deviceMAC = VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress
          
        let ecgHistory = VPDataBaseOperation.veepooSDKGetDeviceOffStoreECG(
            withDate: day.getOneDayDateString(),
            andTableID: deviceMAC
        )
          
        if let ecgHistory = ecgHistory, !ecgHistory.isEmpty {
            print("ECG RAW:", ecgHistory as Any)
            for ecgData in ecgHistory {
                print("ECG duration: \(ecgData.duration)")
                print("Average heart rate: \(ecgData.aveHeart)")
                print("Average HRV: \(ecgData.aveHrv)")
                print("Signal count: \(ecgData.originalSignals?.count ?? 0)")
            }
        } else {
            print("No ECG data found for today")
        }
    }
}
