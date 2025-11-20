//
//  SleepManagerNew.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 20/11/25.
//

import SwiftUI
import Charts

struct SleepSegmentNew: Identifiable {
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

enum SleepTypeNew: Int {
    case awake = 1
    case light = 2
    case deep = 3
    case rem = 4
}

class SleepManagerNew: ObservableObject {
    
    func yStart(for type: SleepTypeNew) -> Double {
        switch type {
        case .deep: return 0
        case .light: return 1
        case .rem: return 2
        case .awake: return 3
        }
    }
    
    func yEnd(for type: SleepTypeNew) -> Double {
        switch type {
        case .deep: return 1
        case .light: return 2
        case .rem: return 3
        case .awake: return 4
        }
    }

    // MARK: - Labels
    func stageName(for value: Int) -> String {
        switch value {
        case 4: return "Awake"
        case 3: return "REM"
        case 2: return "Light"
        case 1: return "Deep"
        default: return ""
        }
    }

    // MARK: - Colors
    func color(for type: SleepTypeNew) -> Color {
        switch type {
        case .awake: return .yellow
        case .light: return .blue.opacity(0.4)
        case .deep: return .blue
        case .rem: return .purple
        }
    }
    
    @Published var sleepSegments: [SleepSegmentNew] = []
    
    func getSleep(day: Int = 0, completion: (() -> Void)? = nil) {
        print("🛌 Get sleep data")

        QCSDKCmdCreator.getFulldaySleepDetailData(byDay: day) { sleeps, naps in
            print("✅ Got full-day sleep data")

            var newSegments: [SleepSegmentNew] = []

            // MARK: - Night sleep
            if let sleeps = sleeps {
                for sleep in sleeps {
                    print("Start Time: \(sleep.happenDate ?? ""), End Time: \(sleep.endTime ?? ""), Duration: \(sleep.total), Type: \(sleep.type.rawValue)")
                    if let startStr = sleep.happenDate,
                       let endStr = sleep.endTime,
                       let start = Self.parseDate(startStr),
                       let end = Self.parseDate(endStr) {

                        let raw = (sleep.type as? Int) ?? sleep.type.rawValue
                        if let type = SleepTypeNew(rawValue: raw) {
                            let segment = SleepSegmentNew(
                                start: start,
                                end: end,
                                type: type
                            )
                            newSegments.append(segment)
                        } else {
                            print("⚠️ Unknown sleep type: \(sleep.type)")
                        }
                    }
                }
            }

            // MARK: - Naps
            if let naps = naps {
                for nap in naps {
                    if let startStr = nap.happenDate,
                       let endStr = nap.endTime,
                       let start = Self.parseDate(startStr),
                       let end = Self.parseDate(endStr) {

                        let raw = (nap.type as? Int) ?? nap.type.rawValue
                        if let type = SleepTypeNew(rawValue: raw) {
                            let segment = SleepSegmentNew(
                                start: start,
                                end: end,
                                type: type
                            )
                            newSegments.append(segment)
                        }
                    }
                }
            }

            let fallAsleepDuration = QCSleepModel.fallAsleepDuration(sleeps)
            let totalSleep = QCSleepModel.sleepDuration(sleeps)
            let totalNaps = QCSleepModel.sleepDuration(naps)

            print("Fall Asleep Duration: \(fallAsleepDuration) minutes")
            print("Total Sleep Duration: \(totalSleep / 60)h \(totalSleep % 60)m")
            print("Total Nap Duration: \(totalNaps / 60)h \(totalNaps % 60)m")

            // ✅ Update Published Properties on Main Thread
            DispatchQueue.main.async {
                self.sleepSegments = newSegments
//                self.totalSleepDurationText = "\(totalSleep / 60)h \(totalSleep % 60)m"
                completion?()
            }

        } fail: {
            print("❌ Failed to get sleep data")
            completion?()
        }
    }
    
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
    
    
    func parseSleepData() -> [SleepSegmentNew] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return sleepSegments
    }
}


