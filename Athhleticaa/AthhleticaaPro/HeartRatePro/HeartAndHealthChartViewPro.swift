//
//  HeartAndHealthChartViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 13/03/26.
//

import SwiftUI
import Charts

struct HeartRateHealthChartViewPro: View {

    let data: [RawHealthData]
    @State private var selectedIndex: Int? = nil

    // Use Int (minutes) instead of Date to avoid DateFormatter locale issues
    var validPoints: [(index: Int, minutes: Int, value: Int)] {
        return data.enumerated().compactMap { index, item in
            guard item.heartRate > 0 else { return nil }

            let parts = item.time.split(separator: ":")
            guard parts.count == 2,
                  let h = Int(parts[0]),
                  let m = Int(parts[1])
            else { return nil }

            return (index, h * 60 + m, item.heartRate)
        }
    }

    var body: some View {
        Group {
            if validPoints.isEmpty {
                Text("No heart rate data")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(validPoints, id: \.index) { point in

                    LineMark(
                        x: .value("Time", point.minutes),
                        y: .value("BPM", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.red)

                    AreaMark(
                        x: .value("Time", point.minutes),
                        y: .value("BPM", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    if let selectedIndex,
                       let selected = validPoints.first(where: { $0.index == selectedIndex }) {
                        RuleMark(x: .value("Selected", selected.minutes))
                            .foregroundStyle(.red.opacity(0.5))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let mins = value.as(Int.self) {
                                Text(String(format: "%02d:%02d", mins / 60, mins % 60))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let y = value.as(Double.self) {
                                Text("\(Int(y))")
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { _ in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let mins: Int = proxy.value(atX: value.location.x) {
                                            let nearest = validPoints.min {
                                                abs($0.minutes - mins) < abs($1.minutes - mins)
                                            }
                                            selectedIndex = nearest?.index
                                        }
                                    }
                            )
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // ← critical
    }
}
