//
//  HeartAndHealthChartViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 13/03/26.
//

import SwiftUI
import Charts

struct HeartRateHealthChartViewPro: View {

    let data: [HeartAndHealthData]

    @State private var selectedIndex: Int? = nil

    var validPoints: [(index: Int, date: Date, value: Int)] {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        return data.enumerated().compactMap { index, item in

            guard item.heartRate > 0,
                  let date = formatter.date(from: item.time)
            else { return nil }

            return (index, date, item.heartRate)
        }
    }

    var body: some View {

        Chart(validPoints, id: \.index) { point in

            LineMark(
                x: .value("Time", point.date),
                y: .value("BPM", point.value)
            )
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Time", point.date),
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

            if let selectedIndex {

                if let selected = validPoints.first(where: { $0.index == selectedIndex }) {

                    RuleMark(x: .value("Selected Time", selected.date))
                }
            }
        }

        .chartXAxis {

            AxisMarks { value in

                AxisGridLine()
                AxisTick()

                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.hour().minute())
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

            GeometryReader { geo in

                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(

                        DragGesture()
                            .onChanged { value in

                                if let date: Date = proxy.value(atX: value.location.x) {

                                    let nearest = validPoints.min {

                                        abs($0.date.timeIntervalSince(date)) <
                                        abs($1.date.timeIntervalSince(date))

                                    }

                                    selectedIndex = nearest?.index
                                }
                            }
                    )
            }
        }

        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
