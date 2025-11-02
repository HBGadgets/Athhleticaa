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
    case light = 2
    case deep = 3
    case rem = 4

    var color: Color {
        switch self {
        case .light: return Color.purple.opacity(0.6)
        case .deep: return Color.purple
        case .rem: return Color.purple.opacity(0.3)
        }
    }

    var label: String {
        switch self {
        case .light: return "Light Sleep"
        case .deep: return "Deep Sleep"
        case .rem: return "REM Sleep"
        }
    }
}


class SleepManager: ObservableObject {
    @Published var sleepSegments: [SleepSegment] = []
    
    func getSleepFromDay(day: Int, completion: (() -> Void)? = nil) {
        print("Get sleep data")
        
        QCSDKCmdCreator.getSleepDetailData(fromDay: day, sleepDatas: { sleepsDict in
            print("Get sleep data successfully")
            
            var newSegments: [SleepSegment] = []
            
            for (dayText, daySleeps) in sleepsDict {
                print("Sleep date: \(dayText)")
                
                for sleep in daySleeps {
                    print("Start Time: \(sleep.happenDate ?? ""), End Time: \(sleep.endTime ?? ""), Duration: \(sleep.total), Type: \(sleep.type)")
                    
                    // Convert to SleepSegment
                    if let startStr = sleep.happenDate,
                       let endStr = sleep.endTime,
                       let start = Self.dateFormatter.date(from: startStr),
                       let end = Self.dateFormatter.date(from: endStr),
                       let type = SleepType(rawValue: sleep.type.rawValue) {
                        
                        let segment = SleepSegment(
                            startTime: start,
                            endTime: end,
                            duration: sleep.total,
                            type: type
                        )
                        newSegments.append(segment)
                    }
                }
                
                let total = QCSleepModel.sleepDuration(daySleeps)
                print("Total duration: \(total / 60)h \(total % 60)m")
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
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
}
