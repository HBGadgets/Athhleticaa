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
                Text("Loading sleep data…")
            } else {
                // Convert your segments into SleepSample
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
                )
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

struct SleepSummaryView: View {
    let summary: SleepManager.Summary

    private var hours: Int { summary.totalMinutes / 60 }
    private var minutes: Int { summary.totalMinutes % 60 }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {

        VStack(spacing: 20) {
            // Total Duration
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

                Text("\(timeFormatter.string(from: summary.startTime))-\(timeFormatter.string(from: summary.endTime))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Circle + Metrics
            HStack {
                // Circular Score
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(summary.score) / 100)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.7)]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 100, height: 100)

                    VStack {
                        Text("\(summary.score)")
                            .font(.system(size: 28, weight: .bold))
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "rocket.fill")
                            .foregroundColor(.black)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(summary.efficiency)%")
                                .font(.headline)
                            Text("Sleep Efficiency")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.black)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.quality)
                                .font(.headline)
                            Text("Sleep Quality")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.leading, 20)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
