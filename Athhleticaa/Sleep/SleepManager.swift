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
        case .light: return Color.blue
        case .deep: return Color.indigo
        case .rem: return Color.teal
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

struct Summary {
    let totalMinutes: Int?
    let startTime: Date?
    let endTime: Date?
    let efficiency: Int?
    let quality: String?
    let score: Int?
}

class SleepManager: ObservableObject {
    @Published var sleepSegments: [SleepSegment] = []
    @Published var totalSleepDurationText: String = ""

    var summary: Summary? {
        guard !sleepSegments.isEmpty else { return nil }

        // Sort by start time
        let sorted = sleepSegments.sorted { $0.startTime < $1.startTime }
        let start = sorted.first!.startTime
        let end = sorted.last!.endTime

        // Total durations (in minutes)
        let totalMinutes = sleepSegments.reduce(0) { $0 + $1.duration }
        let totalPeriod = Int(end.timeIntervalSince(start) / 60)

        // Efficiency = time asleep / total period
        let asleepMinutes = sleepSegments.filter { $0.type != .awake }.reduce(0) { $0 + $1.duration }
        let efficiency = min(100, Int(Double(asleepMinutes) / Double(totalPeriod) * 100))

        // Stage breakdowns
        let deepMinutes = sleepSegments.filter { $0.type == .deep }.reduce(0) { $0 + $1.duration }
        let remMinutes = sleepSegments.filter { $0.type == .rem }.reduce(0) { $0 + $1.duration }
        let lightMinutes = sleepSegments.filter { $0.type == .light }.reduce(0) { $0 + $1.duration }
        let awakeMinutes = sleepSegments.filter { $0.type == .awake }.reduce(0) { $0 + $1.duration }

        // Ratios
        let deepRatio = Double(deepMinutes) / Double(totalMinutes)
        let remRatio = Double(remMinutes) / Double(totalMinutes)
        let lightRatio = Double(lightMinutes) / Double(totalMinutes)
        let awakeRatio = Double(awakeMinutes) / Double(totalMinutes)

        // Base weighted score
        var weightedScore =
            (Double(efficiency) * 0.30) +      // 30% efficiency
            (deepRatio * 100 * 0.25) +         // 25% deep
            (remRatio * 100 * 0.20)            // 20% REM

        // Light Sleep bonus (ideal: 40–55%)
        if lightRatio >= 0.4 && lightRatio <= 0.55 {
            weightedScore += 10
        } else if lightRatio >= 0.3 && lightRatio <= 0.65 {
            weightedScore += 5
        } else {
            weightedScore -= 5  // too low or too high → shallow sleep
        }

        // Awake penalty
        let awakePenalty = awakeRatio * 100 * 0.10
        weightedScore -= awakePenalty

        // Duration bonus
        if totalMinutes >= 420 { // 7h
            weightedScore += 5
        }

        // Optional: Balance bonus if all ratios are within normal sleep composition
        if deepRatio > 0.15 && deepRatio < 0.30 && remRatio > 0.15 && remRatio < 0.25 {
            weightedScore += 5
        }

        // Clamp 0–100
        let score = max(0, min(100, Int(weightedScore)))

        // Quality
        let quality: String
        switch score {
        case 85...100: quality = "Excellent"
        case 70..<85:  quality = "Good"
        case 50..<70:  quality = "Fair"
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
    
    var stageBreakdown: [SleepStageData] {
        guard !sleepSegments.isEmpty else { return [] }

        func total(for type: SleepType) -> Int {
            sleepSegments.filter { $0.type == type }.reduce(0) { $0 + $1.duration }
        }

        return [
            SleepStageData(type: .deep, totalMinutes: total(for: .deep)),
            SleepStageData(type: .light, totalMinutes: total(for: .light)),
            SleepStageData(type: .rem, totalMinutes: total(for: .rem)),
            SleepStageData(type: .awake, totalMinutes: total(for: .awake))
        ]
    }

    func getSleep(day: Int = 0, completion: (() -> Void)? = nil) {
        print("🛌 Get sleep data")

        QCSDKCmdCreator.getFulldaySleepDetailData(byDay: day) { sleeps, naps in
            print("✅ Got full-day sleep data")

            var newSegments: [SleepSegment] = []

            // MARK: - Night sleep
            if let sleeps = sleeps {
                for sleep in sleeps {
                    print("Start Time: \(sleep.happenDate ?? ""), End Time: \(sleep.endTime ?? ""), Duration: \(sleep.total), Type: \(sleep.type.rawValue)")
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
            }

            // MARK: - Naps
            if let naps = naps {
                for nap in naps {
                    if let startStr = nap.happenDate,
                       let endStr = nap.endTime,
                       let start = Self.parseDate(startStr),
                       let end = Self.parseDate(endStr) {

                        let raw = (nap.type as? Int) ?? nap.type.rawValue
                        if let type = SleepType(rawValue: raw) {
                            let segment = SleepSegment(
                                startTime: start,
                                endTime: end,
                                duration: nap.total,
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
                self.totalSleepDurationText = "\(totalSleep / 60)h \(totalSleep % 60)m"
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
}
