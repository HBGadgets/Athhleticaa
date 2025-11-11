//
//  SleepInfoViews.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI
import SleepChartKit

struct MyColorProvider: SleepStageColorProvider {
    func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake: return .yellow
        case .asleepREM: return .teal
        case .asleepCore: return .blue
        case .asleepDeep: return .indigo
        case .asleepUnspecified: return .blue
        case .inBed: return .secondary
        }
    }
}

struct SleepChartViewContainer: View {
    @ObservedObject var sleepManager: SleepManager
    
    var body: some View {
        VStack(spacing: 20) {
            if sleepManager.sleepSegments.isEmpty {
                Text("No data…")
            } else {
                let samples = sleepManager.sleepSegments.map { segment in
                    SleepSample(
                        stage: {
                            switch segment.type {
                            case .awake:     return .awake
                            case .light:    return .asleepCore
                            case .deep:     return .asleepDeep
                            case .rem:      return .asleepREM
                            }
                        }(),
                        startDate: segment.startTime,
                        endDate: segment.endTime
                    )
                }
                
                Text(sleepManager.totalSleepDurationText)

                SleepChartView(
                    samples: samples,
                    colorProvider: MyColorProvider()
                ).frame(height: 100)
            }
        }
        .padding()
    }
}

struct SleepSummaryView: View {
    let summary: Summary
    @Environment(\.colorScheme) var colorScheme

    private var hours: Int { (summary.totalMinutes ?? 0) / 60 }
    private var minutes: Int { (summary.totalMinutes ?? 0) % 60 }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {

        VStack(spacing: 20) {
            // Total Duration
            
            ZStack {
                Circle()
                    .trim(from: 0, to: CGFloat(summary.score ?? 0) / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                
                
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                    .frame(width: 170, height: 170)

                VStack {
                    if let scoreText = summary.score {
                            Text("\(scoreText)")
                                .font(.system(size: 28, weight: .bold))
                        } else {
                            Text("0")
                                .font(.system(size: 28, weight: .bold))
                        }
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                VStack(spacing: 6) {
                    Text("Total Duration")
                        .font(.headline)
                        .foregroundColor(.gray)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(hours)")
                            .font(.system(size: 42, weight: .bold))
                        Text("H")
                            .font(.title3)
                        Text("\(minutes)")
                            .font(.system(size: 42, weight: .bold))
                        Text("M")
                            .font(.title3)
                    }

                    Text("\(timeFormatter.string(from: summary.startTime ?? Date()))-\(timeFormatter.string(from: summary.endTime ?? Date()))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            

            // Circle + Metrics
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    VStack(alignment: .leading, spacing: 2) {
                        if let efficiencyScore = summary.efficiency {
                            Text("\(efficiencyScore)%")
                                .font(.headline)
                        } else {
                            Text("0")
                                .font(.headline)
                        }
                        Text("Sleep Efficiency")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(summary.quality ?? "")
                            .font(.headline)
                        Text("Sleep Quality")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
}
