//
//  BloodOxygenDotChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 04/11/25.
//

import Charts
import SwiftUI

struct BloodOxygenDotChart: View {
    let data: [BloodOxygenModel]
    @ObservedObject var ringManager: QCCentralManager
    var selectedViewSpo2: BloodOxygenModel? {
        guard let selected = ringManager.timeChartBloodOxygen else { return nil }
        return ringManager.bloodOxygenManager.readings.min {
            abs($0.date.timeIntervalSince(selected)) < abs($1.date.timeIntervalSince(selected))
        }
    }
    
    var body: some View {
        let validData = data.filter { $0.soa2 > 0 }

        VStack(alignment: .leading, spacing: 16) {
            if validData.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let firstDate = validData.first!.date
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: firstDate)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: firstDate)!

                Chart {
                    ForEach(validData, id: \.date) { item in
                        PointMark(
                            x: .value("Time", item.date),
                            y: .value("SpO₂", item.soa2)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                    }
                    if let selected = ringManager.timeChartBloodOxygen {
                        // 1. Full-height thin line
                        RuleMark(x: .value("Selected", selected))
                            .foregroundStyle(.yellow)
                            .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                }
                .chartXScale(domain: startOfDay...endOfDay)
                .chartYScale(domain: 80...100)

                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Color.gray)
                        AxisTick().foregroundStyle(Color.gray)
                        AxisValueLabel {
                            if let yValue = value.as(Double.self) {
                                Text("\(Int(yValue))%")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Color.gray)
                        AxisTick().foregroundStyle(Color.gray)
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            }
                        }
                    }
                }
                .chartXSelection(value: $ringManager.timeChartBloodOxygen)
                .onChange(of: ringManager.timeChartBloodOxygen) { _, newValue in
                    if let selected = selectedViewSpo2 {
                        if selectedViewSpo2?.minSoa2 != 0 {
                            if ringManager.lastHapticDate != selected.date {
                                let generator = UIImpactFeedbackGenerator(style: .rigid)
                                generator.prepare()
                                generator.impactOccurred()
                                ringManager.lastHapticDate = selected.date
                            }
                        }
                        ringManager.spo2ValueChart = "\(String(format: "%.0f", selected.minSoa2))% - \(String(format: "%.0f", selected.maxSoa2))%"
                        ringManager.timeChartBloodOxygen = selected.date
                    }
                }
            }
        }
    }
}
