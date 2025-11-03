//
//  SleepManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUICore

struct SleepSegment: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let duration: Int
    let type: SleepType
}

enum SleepType: Int {
    case awake = 1
    case light = 2
    case deep = 3
    case rem = 4

    var color: Color {
        switch self {
        case .awake: return Color.yellow
        case .light: return Color.purple.opacity(0.6)
        case .deep: return Color.purple
        case .rem: return Color.purple.opacity(0.3)
        }
    }

    var label: String {
        switch self {
        case .awake: return "Wake"
        case .light: return "Light Sleep"
        case .deep: return "Deep Sleep"
        case .rem: return "REM Sleep"
        }
    }
}


class SleepManager: ObservableObject {
    @Published var sleepSegments: [SleepSegment] = []
    @Published var totalSleepDurationText: String = ""
    
    struct Summary {
            let totalMinutes: Int
            let startTime: Date
            let endTime: Date
            let efficiency: Int
            let quality: String
            let score: Int
        }

        var summary: Summary? {
            guard !sleepSegments.isEmpty else { return nil }

            // Sort segments by start time
            let sorted = sleepSegments.sorted { $0.startTime < $1.startTime }

            let start = sorted.first!.startTime
            let end = sorted.last!.endTime

            // Calculate total sleep duration (in minutes)
            let totalMinutes = sleepSegments.reduce(0) { $0 + $1.duration }

            // Estimate sleep efficiency (for demo)
            // Efficiency = (Total sleep time / total period) * 100
            let totalPeriod = Int(end.timeIntervalSince(start) / 60)
            let efficiency = min(100, Int(Double(totalMinutes) / Double(totalPeriod) * 100))

            // Score — rough example (you can replace this with actual device data)
            let score = Int(Double(efficiency) * 0.9)

            // Quality based on efficiency
            let quality: String
            switch efficiency {
            case 85...100: quality = "Good"
            case 70..<85:  quality = "Fair"
            default:       quality = "Poor"
            }

            return Summary(
                totalMinutes: totalMinutes,
                startTime: start,
                endTime: end,
                efficiency: efficiency,
                quality: quality,
                score: score
            )
        }
    
    func getSleepFromDay(day: Int, completion: (() -> Void)? = nil) {
        print("Get sleep data")
        
        QCSDKCmdCreator.getSleepDetailData(fromDay: day, sleepDatas: { sleepsDict in
            print("Get sleep data successfully")
            
            var newSegments: [SleepSegment] = []
            var totalSleepText = ""
            
            for (dayText, daySleeps) in sleepsDict {
                print("Sleep date: \(dayText)")
                
                for sleep in daySleeps {
                    print("Start Time: \(sleep.happenDate ?? ""), End Time: \(sleep.endTime ?? ""), Duration: \(sleep.total), Type: \(sleep.type)")
                    
                    // Convert to SleepSegment
                    if let startStr = sleep.happenDate,
                       let endStr = sleep.endTime,
                       let start = Self.parseDate(startStr),
                       let end = Self.parseDate(endStr) {
                        
                        let raw = (sleep.type as? Int) ?? sleep.type.rawValue
                        if let type = SleepType(rawValue: raw) {
                            let segment = SleepSegment(
                                startTime: start,
                                endTime: end,
                                duration: sleep.total,
                                type: type
                            )
                            newSegments.append(segment)
                        } else {
                            print("⚠️ Unknown sleep type: \(sleep.type)")
                        }
                    }
                }
                
                let total = QCSleepModel.sleepDuration(daySleeps)
                totalSleepText = "\(total / 60)h \(total % 60)m"
                print(totalSleepText)
            }
            
            // Update UI
            DispatchQueue.main.async {
                self.sleepSegments = newSegments
                completion?()
            }
        }, fail: {
            print("Failed to get sleep")
            completion?()
        })
    }
    
//    private static let dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return f
//    }()
    
    private static func parseDate(_ string: String) -> Date? {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy/MM/dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            f.dateFormat = format
            if let date = f.date(from: string) {
                return date
            }
        }
        print("⚠️ Could not parse date:", string)
        return nil
    }
}
