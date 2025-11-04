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
        // Filter out invalid readings
        let validData = data.filter { $0.soa2 > 0 }
        // Define start and end of the same day
        guard let firstDate = validData.first?.date else {
            return AnyView(Text("No data available").foregroundColor(.gray))
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: firstDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: firstDate)!
        
        return AnyView (
            Chart(validData) { item in
                LineMark(
                    x: .value("Time", item.date),
                    y: .value("SpO₂", item.soa2)
                )
                .foregroundStyle(
                    Color.white
                )
                
                PointMark(
                    x: .value("Time", item.date),
                    y: .value("SpO₂", item.soa2)
                )
                .symbol(Circle())
                .symbolSize(40)
                .foregroundStyle(
                    Color.white
                )
            }
            .chartYScale(domain: 90...100)
            .chartXScale(domain: startOfDay...endOfDay)
            .chartXAxis {
                AxisMarks() { value in
                    AxisGridLine().foregroundStyle(Color.white)
                    AxisTick().foregroundStyle(Color.white)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            
            // ✅ Custom Y Axis
            .chartYAxis {
                AxisMarks() { value in
                    AxisGridLine().foregroundStyle(Color.white)
                    AxisTick().foregroundStyle(Color.white)
                    AxisValueLabel {
                        if let yValue = value.as(Double.self) {
                            Text("\(Int(yValue))%")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .foregroundStyle(Color.white)
            .frame(height: 250)
            .padding()
            .background(Color(.systemGray6).opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        
    }
}
