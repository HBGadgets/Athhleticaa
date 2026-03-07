//
//  SleepSummaryChartView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 03/11/25.
//

import SwiftUI
import Charts

struct SleepSummaryChartView: View {
    @ObservedObject var sleepManager: SleepManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Stages Breakdown")
                .font(.headline)
                .padding(.horizontal)

            RuleChartView(sleepManager: sleepManager)
                .padding(.horizontal, 5)
        }
    }
}

struct RuleChartView: View {
    @ObservedObject var sleepManager: SleepManager

    private func formattedDuration(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    var body: some View {
        let stages = sleepManager.stageBreakdown

        Chart(stages) { stage in
            let duration = stage.totalMinutes
            let label = stage.type.label
            let color = stage.type.color

            RuleMark(
                xStart: .value("Start", 0),
                xEnd: .value("Duration", duration),
                y: .value("Stage", label)
            )
            .lineStyle(StrokeStyle(lineWidth: 12, lineCap: .round))
            .foregroundStyle(color)
            .annotation(position: .trailing) {
                Text(formattedDuration(duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) {
                AxisTick()
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
}
