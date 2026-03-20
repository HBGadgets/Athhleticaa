//
//  DetailDataClass.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 16/03/26.
//

struct RawHealthData: Identifiable {
    let id = UUID()
    let time: String

    let heartRate: Int
    let steps: Int
    let sportValue: Int

    let calories: Double
    let distance: Double

    let systolic: Int
    let diastolic: Int

    let met: Double
    let stress: Int
}

struct Stat {
    let min: Int
    let max: Int
    let avg: Int
}

struct RawHealthDataStat {
    let heart: Stat?
    let systolic: Stat?
    let diastolic: Stat?
    let met: Stat?
    let stress: Stat?
}

class DetailDataManagerPro: ObservableObject {
    
    @Published var detailData: [RawHealthData] = []
    
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
    
    func avgPPGValue(_ any: Any?) -> Int {
        guard let arr = any as? NSArray else { return 0 }
        
        var validValues: [Int] = []
        for i in 0..<arr.count {
            let elem = arr.object(at: i)
            
            var v: Int? = nil
            if let n = elem as? NSNumber {
                v = n.intValue
            } else if let s = elem as? String {
                v = Int(s)
            }
            
            if let val = v, val > 0 {
                validValues.append(val)
            }
        }
        
        guard !validValues.isEmpty else { return 0 }
        return validValues.reduce(0, +) / validValues.count
    }
    
    func calculateStats<T: BinaryInteger>(_ values: [T]) -> Stat? {
        let valid = values.map { Double($0) }.filter { $0 > 0 }
        guard !valid.isEmpty else { return nil }
        
        let minVal = valid.min()!
        let maxVal = valid.max()!
        let avgVal = valid.reduce(0, +) / Double(valid.count)
        
        return Stat(min: Int(minVal), max: Int(maxVal), avg: Int(avgVal))
    }

    func calculateStatsDouble(_ values: [Double]) -> Stat? {
        let valid = values.filter { $0 > 0 }
        guard !valid.isEmpty else { return nil }
        
        let minVal = valid.min()!
        let maxVal = valid.max()!
        let avgVal = valid.reduce(0, +) / Double(valid.count)
        
        return Stat(min: Int(minVal), max: Int(maxVal), avg: Int(avgVal))
    }
    
    func computeStats(from data: [RawHealthData]) -> RawHealthDataStat {
        
        let heartStats = calculateStats(data.map { $0.heartRate })
        let systolicStats = calculateStats(data.map { $0.systolic })
        let diastolicStats = calculateStats(data.map { $0.diastolic })
        let metStats = calculateStatsDouble(data.map { $0.met })
        let stressStats = calculateStats(data.map { $0.stress })
        
        return RawHealthDataStat(heart: heartStats, systolic: systolicStats, diastolic: diastolicStats, met: metStats, stress: stressStats)
    }
    
    func readDetailDataByDay(day: Int, completion: @escaping ([RawHealthData]?) -> Void) {

        guard let deviceID = VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress
        else { completion([]); return ;}

        guard let raw =
            VPDataBaseOperation.veepooSDKGetOriginalData(
                withDate: day.getOneDayDateString(),
                andTableID: deviceID
            ) as? [String: [String: Any]]
        else { completion([]); return ; }

        var results: [RawHealthData] = []

        for (time, values) in raw {
            
            let heartValue = intValue(values["heartValue"])

            let finalHeartRate: Int
            if heartValue > 0 {
                finalHeartRate = heartValue
            } else {
                finalHeartRate = avgPPGValue(values["ppgs"])
            }

            let model = RawHealthData(
                time: time,
                heartRate: finalHeartRate,
                steps: intValue(values["stepValue"]),
                sportValue: intValue(values["sportValue"]),
                calories: doubleValue(values["calValue"]),
                distance: doubleValue(values["disValue"]),
                systolic: intValue(values["systolic"]),
                diastolic: intValue(values["diastolic"]),
                met: doubleValue(values["met"]),
                stress: intValue(values["stress"])
            )

            results.append(model)
        }

        

        DispatchQueue.main.async {
            let sortedData = results.sorted {
                let t1 = $0.time.split(separator: ":")
                let t2 = $1.time.split(separator: ":")

                let m1 = Int(t1[0])! * 60 + Int(t1[1])!
                let m2 = Int(t2[0])! * 60 + Int(t2[1])!

                return m1 < m2
            }
            completion(sortedData)
        }
    }
}
