//
//  StressChartView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/11/25.
//

import SwiftUI
import Charts

struct StressChartView: View {
    let stressData: StressModel
    @ObservedObject var ringManager: QCCentralManager
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        // total seconds in a day
        let totalSecondsInDay = 24 * 60 * 60
        
        // compute valid heart rate points (exclude zeros)
        let validRates = stressData.stresses.enumerated()
            .filter { $0.element > 0 }
            .map { (index, value) in
                (time: Double(index * stressData.secondInterval), stress: value)
            }
            .filter { $0.time <= Double(totalSecondsInDay) } // just in case
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Stress Chart")
                .font(.headline)
            
            Chart {
                ForEach(validRates, id: \.time) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Stress", point.stress)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                    
                    AreaMark(
                        x: .value("Time", point.time),
                        y: .value("Stress", point.stress)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.red.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                if let selectedIndex {
                    let time = Double(selectedIndex * stressData.secondInterval)

                    RuleMark(x: .value("Selected Time", time))
                        .foregroundStyle(.yellow)
                }

            }
            // ✅ Fix x-axis to show full day (12 AM to 12 AM)
            .chartXScale(domain: 0...Double(totalSecondsInDay))
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                let tickValues = Array(stride(from: 0, through: totalSecondsInDay, by: 6 * 60 * 60)).map(Double.init)
                
                AxisMarks(values: tickValues) { value in
                    AxisGridLine()
                    AxisTick()
                    if let time = value.as(Double.self) {
                        AxisValueLabel(formattedShortTime(from: time))
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    let origin = geo[proxy.plotAreaFrame].origin
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let xInPlot = value.location.x - origin.x
                                    if let time: Double = proxy.value(atX: xInPlot) {
                                        let clamped = min(max(time, 0), Double(totalSecondsInDay))

                                        // find nearest validRates point by time
                                        let rawIndex = Int(clamped / Double(stressData.secondInterval))

                                        selectedIndex = min(max(rawIndex, 0), stressData.stresses.count - 1)
                                    }
                                }

                        )
                }
            }
            .onChange(of: selectedIndex) { _, newIndex in
                if let index = newIndex {
                    let stress = stressData.stresses[index]
                    let time = Double(index * stressData.secondInterval)

                    // only update label if stress > 0
                    if stress > 0 {
                        ringManager.stressValueChart = "\(stress)"
                    } else {
                        ringManager.stressValueChart = "—"
                    }

                    ringManager.timeChartStress = dateFromSecondsSinceMidnight(time)

                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }

            .frame(height: 250)
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private func formattedTime(from seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // ⏰ always start at 12 AM
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formattedShortTime(from seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    
    func dateFromSecondsSinceMidnight(_ seconds: Double) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date()) // today at 12 AM
        return startOfDay.addingTimeInterval(seconds)
    }
}
