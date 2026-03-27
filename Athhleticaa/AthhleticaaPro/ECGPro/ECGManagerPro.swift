//
//  ECGManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/03/26.
//

class ECGManagerPro: ObservableObject {
    
    func startECGTest(ringManagerPro: RingManagerPro) {
        
        VPBleCentralManage.sharedBleManager()?
            .peripheralManage.veepooSDKPTTTest(true, valueBlock: { (valueModel) in
                ringManagerPro.vpttTestModel = valueModel
            }, signal: { (signals) in
                guard let signalArray = signals else { return }
            })
        
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestECGStart(true) { testECGState, testProgress, testModel in
            switch testECGState {
            case .start:
                print("ECG test starting")
            case .testing:
                print("ECG testing, progress: \(testProgress)%")
                DispatchQueue.main.async {
                    ringManagerPro.handRemovedFromElectrode = false
                }
                // Update UI with real-time data
                if let model = testModel {
                    DispatchQueue.main.async {
                        let newModel = VPECGTestDataModel()
                        newModel.filterSignals = model.filterSignals
                        newModel.ecgType = model.ecgType
                        newModel.type = model.type
                        // copy other fields as needed

                        ringManagerPro.vpECGTestDataModel = newModel
                    }
                }
            case .complete:
                print("ECG test completed")
                // Final update with complete data
                if let model = testModel {
                    DispatchQueue.main.async {
                        ringManagerPro.vpECGTestDataModel = model
                    }
                }
            case .noFunction:
                print("Device does not support ECG")
                
            case .notLead:  // 导联脱落
                print("Hand removed from electrode")
                DispatchQueue.main.async {
                    ringManagerPro.handRemovedFromElectrode = true
                }
                
            default:
                break
            }
        }
    }
    
    func stopECGTest() {
        
        VPBleCentralManage.sharedBleManager()?
            .peripheralManage.veepooSDKPTTTest(false, valueBlock: { (valueModel) in
                print("vpttesting stopped")
            }, signal: { (signals) in
                
            })
        
        VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKTestECGStart(false) { testECGState, testProgress, testModel in
            print("ecg test stopped")
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
