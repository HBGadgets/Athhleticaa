//
//  ActivityCharts.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 08/11/25.
//

import SwiftUI
import Charts

//struct PedometerChartsView: View {
//    @ObservedObject var pedometerManager: PedometerManager
//    @State private var selectedHour: Int? = nil
//
//    var body: some View {
//        VStack(spacing: 24) {
//            
//            InteractiveBarChart(
//                title: "Steps",
//                color: .orange,
//                data: pedometerManager.hourlyData.map { (hour: $0.hour, value: Double($0.steps)) },
//                selectedHour: $selectedHour
//            )
//            
//            InteractiveBarChart(
//                title: "Distance (m)",
//                color: .blue,
//                data: pedometerManager.hourlyData.map { (hour: $0.hour, value: Double($0.distance)) },
//                selectedHour: $selectedHour
//            )
//
//            InteractiveBarChart(
//                title: "Calories (kcal)",
//                color: .red,
//                data: pedometerManager.hourlyData.map { (hour: $0.hour, value: $0.calories) },
//                selectedHour: $selectedHour
//            )
//        }
//    }
//}
//
//struct InteractiveBarChart: View {
//    var title: String
//    var color: Color
//    var data: [(hour: Int, value: Double)]
//    @Binding var selectedHour: Int?
//
//    var body: some View {
//        ChartBox(title: title, color: color) {
//            Chart {
//                ForEach(data, id: \.hour) { item in
//                    BarMark(
//                        x: .value("Hour", item.hour),
//                        y: .value(title, item.value)
//                    )
//                    .foregroundStyle(color.gradient)
//                    .cornerRadius(4)
//                    
//                    // Highlight bar
//                    if selectedHour == item.hour {
//                        RuleMark(x: .value("Selected", item.hour))
//                            .foregroundStyle(color)
//                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
//                            .annotation(position: .top) {
//                                VStack {
//                                    Text("\(hourLabel(for: item.hour))")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                    Text("\(Int(item.value))")
//                                        .font(.headline)
//                                        .foregroundColor(color)
//                                }
//                                .padding(6)
//                                .background(.ultraThinMaterial)
//                                .cornerRadius(8)
//                            }
//                    }
//                }
//            }
//            .chartXAxis {
//                AxisMarks(values: [0, 6, 12, 18, 24]) { value in
//                    if let hour = value.as(Int.self) {
//                        AxisValueLabel(hourLabel(for: hour))
//                    }
//                }
//            }
//            .chartXScale(domain: 0...24)
//            .chartYAxis {
//                AxisMarks(position: .leading)
//            }
//            .frame(height: 180)
//            .chartOverlay { proxy in
//                GeometryReader { geometry in
//                    Rectangle()
//                        .fill(.clear)
//                        .contentShape(Rectangle())
//                        .gesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    let origin = geometry[proxy.plotAreaFrame].origin
//                                    let locationX = value.location.x - origin.x
//                                    
//                                    if let hour: Int = proxy.value(atX: locationX) {
//                                        selectedHour = hour
//                                    }
//                                }
//                                .onEnded { _ in
//                                    // Optionally keep selection or reset:
//                                    // selectedHour = nil
//                                }
//                        )
//                }
//            }
//        }
//    }
//
//    private func hourLabel(for hour: Int) -> String {
//        switch hour {
//        case 0: return "12 AM"
//        case 6: return "6 AM"
//        case 12: return "12 PM"
//        case 18: return "6 PM"
//        case 24: return "12 AM"
//        default:
//            let period = hour < 12 ? "AM" : "PM"
//            let displayHour = hour % 12 == 0 ? 12 : hour % 12
//            return "\(displayHour) \(period)"
//        }
//    }
//}


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
