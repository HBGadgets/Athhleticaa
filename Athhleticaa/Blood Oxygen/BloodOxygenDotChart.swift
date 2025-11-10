//
//  BloodOxygenDotChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 04/11/25.
//

import SwiftUI
import Charts

struct BloodOxygenDotChart: View {
    let data: [BloodOxygenModel]
    
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
                                LineMark(
                                    x: .value("Time", item.date),
                                    y: .value("SpO₂", item.soa2)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(.blue)
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
//                                            .foregroundColor(.white.opacity(0.8))
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
//                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                        .frame(height: 250)
                    }
                }
    }

    
    
    // MARK: - Helpers
    
//    private func formattedTime(from seconds: Double) -> String {
//        let date = Date(timeIntervalSince1970: seconds)
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0) // ⏰ always start at 12 AM
//        formatter.dateFormat = "h:mm a"
//        return formatter.string(from: date)
//    }
//    
//    private func formattedShortTime(from seconds: Double) -> String {
//        let date = Date(timeIntervalSince1970: seconds)
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "h a"
//        return formatter.string(from: date)
//    }
    
//    var body: some View {
//        // Filter out invalid readings
//        let validData = data.filter { $0.soa2 > 0 }
//        // Define start and end of the same day
//        guard let firstDate = validData.first?.date else {
//            return AnyView(Text("No data available").foregroundColor(.gray))
//        }
//        
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: firstDate)
//        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: firstDate)!
//        
//        return AnyView (
//            Chart(validData) { item in
//                LineMark(
//                    x: .value("Time", item.date),
//                    y: .value("SpO₂", item.soa2)
//                )
//                .foregroundStyle(
//                    Color.white
//                )
//                
//                PointMark(
//                    x: .value("Time", item.date),
//                    y: .value("SpO₂", item.soa2)
//                )
//                .symbol(Circle())
//                .symbolSize(40)
//                .foregroundStyle(
//                    Color.white
//                )
//            }
//            .chartYScale(domain: 90...100)
//            .chartXScale(domain: startOfDay...endOfDay)
//            .chartXAxis {
//                AxisMarks() { value in
//                    AxisGridLine().foregroundStyle(Color.white)
//                    AxisTick().foregroundStyle(Color.white)
//                    AxisValueLabel {
//                        if let date = value.as(Date.self) {
//                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
//                }
//            }
//            
//            // ✅ Custom Y Axis
//            .chartYAxis {
//                AxisMarks() { value in
//                    AxisGridLine().foregroundStyle(Color.white)
//                    AxisTick().foregroundStyle(Color.white)
//                    AxisValueLabel {
//                        if let yValue = value.as(Double.self) {
//                            Text("\(Int(yValue))%")
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
//                }
//            }
//            .foregroundStyle(Color.white)
//            .frame(height: 250)
//            .padding()
//            .background(Color(.systemGray6).opacity(0))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        )
//        
//    }
}
