//
//  HeartRateManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 13/03/26.
//

struct HeartAndHealthData: Identifiable {
    let id = UUID()
    let time: String
    let heartRate: Int
    let sportValue: Int
    let steps: Int
    let calories: Double
    let distance: Double
}

class HeartRateManagerPro: ObservableObject {
    
    @Published var heartData: [HeartAndHealthData] = []
    @Published var detailData = []
    
    
    var heartDict = [String : [String: String]]()
    
    func intValue(_ any: Any?) -> Int {
        if let int = any as? Int { return int }
        if let str = any as? String { return Int(str) ?? 0 }
        return 0
    }
    
    func doubleValue(_ any: Any?) -> Double {
        if let double = any as? Double { return double }
        if let str = any as? String { return Double(str) ?? 0 }
        return 0
    }
    
    
    func readHeartRateDataByDay(day: Int, completion: @escaping ([HeartAndHealthData]?) -> Void) {
        
        let heartOnedayData = VPDataBaseOperation.veepooSDKGetOriginalChangeHalfHourData(withDate: day.getOneDayDateString(), andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        
        if heartOnedayData == nil {
            heartDict = [String : [String: String]]()
        }else {
            heartDict = heartOnedayData as! [String : [String : String]]
        }
        print(heartDict)
        
        var results: [HeartAndHealthData] = []
        
        for (time, values) in heartDict {
            
            let model = HeartAndHealthData(
                time: time,
                heartRate: intValue(values["heartValue"]),
                sportValue: intValue(values["sportValue"]),
                steps: intValue(values["stepValue"]),
                calories: doubleValue(values["calValue"]),
                distance: doubleValue(values["disValue"])
            )
            
            results.append(model)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let sorted = results.sorted {
            (formatter.date(from: $0.time) ?? .distantPast) <
                (formatter.date(from: $1.time) ?? .distantPast)
        }
        
        DispatchQueue.main.async {
            self.heartData = sorted
            print("sorted =====>>>> \(sorted)")
            completion(sorted)
        }
    }
    
    func readLiveHeartRate(ringManagerPro: RingManagerPro) {
        VPBleCentralManage.sharedBleManager()
            .peripheralManage
            .veepooSDKTestHeartStart(true) { (testHeartState, heartValue) in
                
                DispatchQueue.main.async {
                    ringManagerPro.heartRateTestState = testHeartState
                    ringManagerPro.heartRate = Int(heartValue)
                }
            }
    }
    
    func stopLiveHeartRate() {
        VPBleCentralManage.sharedBleManager()
            .peripheralManage
            .veepooSDKTestHeartStart(false) { (testHeartState, heartValue) in
                // Callback when stopping - can be ignored or used for cleanup
                print("Heart rate test stopped with state: \(testHeartState)")
            }
    }
}
