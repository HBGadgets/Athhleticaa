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

    @State private var selectedIndex: Int? = nil
    @State private var persistentSelectedDate: Date? = nil

    var body: some View {
        let validData = data.filter { $0.soa2 > 0 }

        VStack(alignment: .leading, spacing: 16) {
            if validData.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            let firstDate = validData.first?.date
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: firstDate ?? Date())
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: firstDate ?? Date())!
            let totalSecondsInDay = 24 * 3600

            Chart {
                ForEach(validData, id: \.date) { item in
                    PointMark(
                        x: .value("Time", item.date),
                        y: .value("SpO₂", item.soa2)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                }

                if let selected = persistentSelectedDate {
                    RuleMark(x: .value("Selected", selected))
                        .foregroundStyle(.yellow)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartXScale(domain: startOfDay...endOfDay)
            .chartYScale(domain: 80...100)

            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(.gray)
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))%")
                        }
                    }
                }
            }

            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(.gray)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                        }
                    }
                }
            }

            // MARK: - Drag Gesture Overlay
            .chartOverlay { proxy in
                GeometryReader { geo in
                    let origin = geo[proxy.plotAreaFrame].origin

                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - origin.x

                                    // Read Date from chart space
                                    if let date: Date = proxy.value(atX: x) {

                                        let seconds = date.timeIntervalSince(startOfDay)
                                        let clamped = min(max(seconds, 0), Double(totalSecondsInDay))

                                        // convert time → nearest index
                                        let nearestIndex = findNearestIndex(in: data, secondsSinceStart: clamped, startOfDay: startOfDay)

                                        selectedIndex = nearestIndex
                                        persistentSelectedDate = data[nearestIndex].date
                                    }
                                }
                                .onEnded { _ in
                                    // keep the line persistent, do not remove selection
                                }
                        )
                }
            }

            .onChange(of: selectedIndex) { _, newIndex in
                guard let index = newIndex, index < data.count else { return }

                let selected = data[index]
                
                if selected.minSoa2 != 0 {
                    ringManager.spo2ValueChart =
                        "\(Int(selected.minSoa2))% - \(Int(selected.maxSoa2))%"

                    ringManager.timeChartBloodOxygen = selected.date
                    
                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
        }
    }

    // MARK: - Helper: Find nearest validData element
    func findNearestIndex(in items: [BloodOxygenModel], secondsSinceStart: Double, startOfDay: Date) -> Int {
        let targetDate = startOfDay.addingTimeInterval(secondsSinceStart)

        let closest = items.enumerated().min { a, b in
            abs(a.element.date.timeIntervalSince(targetDate)) <
            abs(b.element.date.timeIntervalSince(targetDate))
        }

        return closest?.offset ?? 0
    }
}
