//
//  HRVChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI
import Charts

struct HRVChartView: View {
    let data: HRVModel
    
    var body: some View {
        let totalSecondsInDay = 24 * 60 * 60
        // Convert HRV values into time-based data points
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let baseDate = dateFormatter.date(from: data.date) else {
            return AnyView(Text("Invalid date"))
        }
        
        // Each value corresponds to one timestamp = baseDate + (index * interval)
        let points: [HRVPoint] = data.values.enumerated().map { index, value in
            let time = calendar.date(byAdding: .second, value: index * data.interval, to: baseDate)!
            return HRVPoint(time: time, value: value)
        }
        
        let validPoints = points.filter { $0.value > 0 }
        
        
        return AnyView(
            Chart(validPoints) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("HRV", point.value)
                )
                .foregroundStyle(.red)
                
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("HRV", point.value)
                )
                .symbol(Circle())
                .symbolSize(40)
                .foregroundStyle(
                    Color.red
                )
            }
            .chartXAxis {
                AxisMarks() { value in
                    AxisGridLine().foregroundStyle(Color.gray)
                    AxisTick().foregroundStyle(Color.gray)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
//                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                }
            }
            
            .chartYAxis {
                AxisMarks() { value in
                    AxisGridLine().foregroundStyle(Color.gray)
                    AxisTick().foregroundStyle(Color.gray)
                    AxisValueLabel {
                        if let yValue = value.as(Double.self) {
                            Text("\(Int(yValue))")
//                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                }
            }
            .chartXScale(domain: baseDate...(calendar.date(byAdding: .day, value: 1, to: baseDate)!))
            .foregroundStyle(Color.gray)
            .frame(height: 250)
            .padding()
            .background(Color(.systemGray6).opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }
}

struct HRVPoint: Identifiable {
    let id = UUID()
    let time: Date
    let value: Int
}
