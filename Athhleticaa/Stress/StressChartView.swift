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
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        // total seconds in a day
        let totalSecondsInDay = 24 * 60 * 60
        
        // compute valid heart rate points (exclude zeros)
        let validRates = stressData.stresses.enumerated()
            .filter { $0.element > 0 }
            .map { (index, value) in
                (time: Double(index * stressData.secondInterval), bpm: value)
            }
            .filter { $0.time <= Double(totalSecondsInDay) } // just in case
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Stress Chart")
                .font(.headline)
            
            Chart {
                ForEach(validRates, id: \.time) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("BPM", point.bpm)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                    
                    AreaMark(
                        x: .value("Time", point.time),
                        y: .value("BPM", point.bpm)
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
                    
                    PointMark(
                        x: .value("Time", selected.time),
                        y: .value("BPM", selected.bpm)
                    )
                    .symbolSize(100)
                    .foregroundStyle(.blue)
                    
                    RuleMark(x: .value("Selected Time", selected.time))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.gray.opacity(0.6))
                        .annotation(position: .top, spacing: 0) {
                            VStack {
                                Text("\(Int(selected.bpm)) bpm")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text(formattedTime(from: selected.time))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
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
                                }
                        )
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
}
