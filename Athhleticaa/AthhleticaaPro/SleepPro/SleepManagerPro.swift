//
//  SleepManagerPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 18/03/26.
//

struct SleepSegmentPro: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let type: SleepTypeNew
    
    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }
    
    var y0: Double {
        switch type { case .deep: 0; case .light: 1; case .rem: 2; case .awake: 3 }
    }

    var y1: Double {
        switch type { case .deep: 1; case .light: 2; case .rem: 3; case .awake: 4 }
    }
}

enum SleepTypePro: Int {
    case awake = 4
    case light = 1
    case deep = 0
    case rem = 2
}

class SleepManagerPro: ObservableObject {
    
    func mapType(_ value: Int) -> SleepTypeNew {
        switch value {
        case 0: return .deep
        case 1: return .light
        case 2: return .rem
        case 4: return .awake
        case 3: return .awake // or ignore insomnia if you want
        default: return .awake
        }
    }
    
    func buildSleepSegments(
        parsed: [[AnyHashable: Any]],
        sleepStart: Date,
        onePointSeconds: TimeInterval
    ) -> [SleepSegmentNew] {
        
        guard !parsed.isEmpty else { return [] }
        
        var segments: [SleepSegmentNew] = []
        
        var currentTypeInt = parsed[0]["type"] as! Int
        var currentStartIndex = parsed[0]["index"] as! Int
        
        for i in 1..<parsed.count {
            let item = parsed[i]
            let type = item["type"] as! Int
            let index = item["index"] as! Int
            
            if type != currentTypeInt {
                // close previous segment
                let start = sleepStart.addingTimeInterval(Double(currentStartIndex) * onePointSeconds)
                let end = sleepStart.addingTimeInterval(Double(index) * onePointSeconds)
                
                segments.append(
                    SleepSegmentNew(
                        start: start,
                        end: end,
                        type: mapType(currentTypeInt)
                    )
                )
                
                // start new segment
                currentTypeInt = type
                currentStartIndex = index
            }
        }
        
        // close last segment
        if let last = parsed.last {
            let lastIndex = last["index"] as! Int
            
            let start = sleepStart.addingTimeInterval(Double(currentStartIndex) * onePointSeconds)
            let end = sleepStart.addingTimeInterval(Double(lastIndex + 1) * onePointSeconds)
            
            segments.append(
                SleepSegmentNew(
                    start: start,
                    end: end,
                    type: mapType(currentTypeInt)
                )
            )
        }
        
        return segments
    }
    
    func readSleepDataForToday(retries: Int = 5) {
        let date = (-1).getOneDayDateString()

        let sleepArray = VPDataBaseOperation.veepooSDKGetAccurateSleepData(withDate: date, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)

        if let sleepArray {
            print("sleep data =====>>>> \(sleepArray)")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")  // ← add this
            formatter.timeZone = TimeZone.current
            
            for sleep in sleepArray {
                let sleepData = sleep as! VPAccurateSleepModel
                // 睡眠曲线解析
                print(sleepData.parseSleepLine())
                
                let parsed = sleepData.parseSleepLine()

                print("sleepTime raw value: '\(sleepData.sleepTime ?? "NIL")'") // ← see the real value

                guard let sleepStart = formatter.date(from: sleepData.sleepTime) else {
                    print("❌ Failed to parse sleepTime: \(sleepData.sleepTime)")
                    continue
                }

                let onePoint = TimeInterval(Int(sleepData.onePointDuration) ?? 60)

                let segments = buildSleepSegments(
                    parsed: parsed,
                    sleepStart: sleepStart,
                    onePointSeconds: onePoint
                )

                print("Segments:", segments)
            }
        } else if retries > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.readSleepDataForToday(retries: retries - 1)
            }
        } else {
            print("❌ sleep data still nil after retries")
        }
    }
}
