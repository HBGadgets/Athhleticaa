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
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var cursorMinutes: Int? = nil

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
                    .foregroundColor(.white)
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
                    

                    if let cursor = cursorMinutes {
                            RuleMark(x: .value("Selected Time", cursor))
                                .foregroundStyle(.yellow)
                        }
                }
                .chartXScale(domain: 0...1439)
                .chartYScale(domain: 0...150)
                .chartXAxis {
                    AxisMarks(values: [0, 360, 720, 1080]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let mins = value.as(Int.self) {
                                let hour = mins / 60
                                if hour == 0 {
                                    Text("12 AM")
                                } else if hour < 12 {
                                    Text("\(hour) AM")
                                } else if hour == 12 {
                                    Text("12 PM")
                                } else {
                                    Text("\(hour - 12) PM")
                                }
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
                                            let clamped = max(0, min(1439, mins))
                                            cursorMinutes = clamped  // cursor follows finger freely
                                            let nearest = validPoints.min {
                                                abs($0.minutes - mins) < abs($1.minutes - mins)
                                            }
                                            selectedIndex = nearest?.index
                                        }
                                    }
                            )
                    }
                }
                .onChange(of: selectedIndex, initial: false) { oldValue, newValue in
                      if let index = newValue,
                         let selected = validPoints.first(where: { $0.index == index }) {
                          if selected.value != 0 {
                              ringManagerPro.heartRateValueChart = "\(selected.value)"
                              let hours = selected.minutes / 60
                              let minutes = selected.minutes % 60
                              var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                              components.hour = hours
                              components.minute = minutes
                              if let date = Calendar.current.date(from: components) {
                                  ringManagerPro.timeChartHeartRate = date
                              }
                              let generator = UIImpactFeedbackGenerator(style: .rigid)
                              generator.prepare()
                              generator.impactOccurred()
                          }
                      } else if let selected = validPoints.last {
                          ringManagerPro.heartRateValueChart = "\(selected.value)"
                          let hours = selected.minutes / 60
                          let minutes = selected.minutes % 60
                          var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                          components.hour = hours
                          components.minute = minutes
                          if let date = Calendar.current.date(from: components) {
                              ringManagerPro.timeChartHeartRate = date
                          }
                      }
                  }
                .onDisappear() {
                    ringManagerPro.heartRateValueChart = nil
                    ringManagerPro.timeChartHeartRate = nil
                }
                .padding()
            }
        }
    }
}
