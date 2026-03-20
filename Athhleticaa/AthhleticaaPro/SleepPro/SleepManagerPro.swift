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
    let type: SleepTypePro
    
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
    case awake = 3
    case light = 1
    case deep = 0
    case rem = 2
}

class SleepManagerPro: ObservableObject {
    
    @Published var sleepSegments: [SleepSegmentPro] = []
    @Published var sleepSummary: Summary?
    
    func mapType(_ value: Int) -> SleepTypePro {
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
    ) -> [SleepSegmentPro] {
        
        guard !parsed.isEmpty else { return [] }
        
        var segments: [SleepSegmentPro] = []
        
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
                    SleepSegmentPro(
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
                SleepSegmentPro(
                    start: start,
                    end: end,
                    type: mapType(currentTypeInt)
                )
            )
        }
        
        return segments
    }
    
    func buildSummary(from sleep: VPAccurateSleepModel) -> Summary {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // IMPORTANT
        
        let start = formatter.date(from: sleep.sleepTime)
        let end = formatter.date(from: sleep.wakeTime)
        
        let totalMinutes = Int(sleep.sleepDuration.toInt ?? 0)
        let efficiency = Int(sleep.sleepEfficiencyScore.toInt ?? 0)
        
        // Convert quality (0–4) → readable
        let qualityString: String? = {
            guard let q = Int(sleep.sleepQuality) else { return nil }
            switch q {
            case 0: return "Very Poor"
            case 1: return "Poor"
            case 2: return "Average"
            case 3: return "Good"
            case 4: return "Excellent"
            default: return nil
            }
        }()
        
        // Build a meaningful score (SDK doesn’t give one directly)
        let score = buildScore(from: sleep)
        
        return Summary(
            totalMinutes: totalMinutes,
            startTime: start,
            endTime: end,
            efficiency: efficiency,
            quality: qualityString,
            score: score
        )
    }
    
    func buildScore(from sleep: VPAccurateSleepModel) -> Int? {
        
        let rawScores = [
            Int(sleep.sleepEfficiencyScore),
            Int(sleep.sleepTimeScore),
            Int(sleep.fallAsleepScore)
        ].compactMap { $0 }
        
        guard !rawScores.isEmpty else { return nil }
        
        // Convert each score from 0–5 → 0–100
        let normalized = rawScores.map { $0 * 20 }
        
        let avg = normalized.reduce(0, +) / normalized.count
        return avg
    }
    
    func readSleepDataForToday(retries: Int = 5, completion: (() -> Void)? = nil) {
        let date = (0).getOneDayDateString()

        let sleepArray = VPDataBaseOperation.veepooSDKGetAccurateSleepData(withDate: date, andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress)
        
        var summaryOfToday: Summary?

        if let sleepArray {
//            print("sleep data =====>>>> \(sleepArray)")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")  // ← add this
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            for sleep in sleepArray {
                let sleepData = sleep as! VPAccurateSleepModel
                
                summaryOfToday = buildSummary(from: sleepData)
//                    print("SUMMARY =>", summaryOfToday)
                // 睡眠曲线解析
//                print(sleepData.parseSleepLine())
                
                let parsed = sleepData.parseSleepLine()

//                print("sleepTime raw value: '\(sleepData.sleepTime ?? "NIL")'")

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

                self.sleepSegments.append(contentsOf: segments)
//                print("Segments:", segments)
                
            }
            
            self.sleepSummary = summaryOfToday
            completion?()
        } else if retries > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.readSleepDataForToday(retries: retries - 1)
            }
        } else {
            print("❌ sleep data still nil after retries")
            completion?()
        }
    }
    
    func deriveQuality(deep: Int, total: Int) -> String {
        let ratio = Double(deep) / Double(total)
        
        switch ratio {
        case ..<0.1: return "Very Poor"
        case ..<0.2: return "Poor"
        case ..<0.3: return "Average"
        case ..<0.4: return "Good"
        default: return "Excellent"
        }
    }
}

extension String {
    var toInt: Int? { Int(self) }
}
