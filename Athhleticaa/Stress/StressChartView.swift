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
                
                if let selectedIndex,
                   selectedIndex < validRates.count {
                    let selected = validRates[selectedIndex]
                    
                    RuleMark(x: .value("Selected Time", selected.time))
                        .foregroundStyle(.yellow)
                        .lineStyle(StrokeStyle(lineWidth: 1))
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
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location
                                    if let time: Double = proxy.value(atX: location.x) {
                                        let index = Int(time / Double(stressData.secondInterval))
                                        if index >= 0 && index < validRates.count {
                                            selectedIndex = index
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    selectedIndex = nil
                                    ringManager.stressValueChart = nil
                                    ringManager.timeChartStress = nil
                                }
                        )
                }
            }
            .onChange(of: selectedIndex) { _, newIndex in
//                if let index = newIndex, index < validRates.count {
                if let index = newIndex {
                    let selected = validRates[index]
                    ringManager.stressValueChart = "\(selected.stress)"
                    ringManager.timeChartStress = dateFromSecondsSinceMidnight(selected.time)
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
