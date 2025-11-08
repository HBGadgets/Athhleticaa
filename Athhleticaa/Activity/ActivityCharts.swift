//
//  ActivityCharts.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 08/11/25.
//

import SwiftUI
import Charts

import SwiftUI
import Charts

struct PedometerChartsView: View {
    @ObservedObject var pedometerManager: PedometerManager

    var body: some View {
        VStack(spacing: 24) {
            
            ChartBox(title: "Steps", color: .orange) {
                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Steps", data.steps)
                        )
                        .foregroundStyle(.orange.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                        if let hour = value.as(Int.self) {
                            switch hour {
                            case 0: AxisValueLabel("12 AM")
                            case 6: AxisValueLabel("6 AM")
                            case 12: AxisValueLabel("12 PM")
                            case 18: AxisValueLabel("6 PM")
                            case 24: AxisValueLabel("12 AM")
                            default: AxisValueLabel("")
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }
            
            ChartBox(title: "Distance (m)", color: .blue) {
                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Distance", data.distance)
                        )
                        .foregroundStyle(.blue.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                        if let hour = value.as(Int.self) {
                            switch hour {
                            case 0: AxisValueLabel("12 AM")
                            case 6: AxisValueLabel("6 AM")
                            case 12: AxisValueLabel("12 PM")
                            case 18: AxisValueLabel("6 PM")
                            case 24: AxisValueLabel("12 AM")
                            default: AxisValueLabel("")
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }

            ChartBox(title: "Calories (kcal)", color: .red) {
                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Calories", data.calories)
                        )
                        .foregroundStyle(.red.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                        if let hour = value.as(Int.self) {
                            switch hour {
                            case 0: AxisValueLabel("12 AM")
                            case 6: AxisValueLabel("6 AM")
                            case 12: AxisValueLabel("12 PM")
                            case 18: AxisValueLabel("6 PM")
                            case 24: AxisValueLabel("12 AM")
                            default: AxisValueLabel("")
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }

            
        }
    }
}

struct ChartBox<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var color: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
