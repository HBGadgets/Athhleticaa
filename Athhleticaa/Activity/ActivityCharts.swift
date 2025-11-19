//
//  ActivityCharts.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 08/11/25.
//

import SwiftUI
import Charts

struct PedometerChartsView: View {
    @ObservedObject var pedometerManager: PedometerManager
    @ObservedObject var ringManager: QCCentralManager
    @State private var selectedIndexSteps: Int? = nil
    @State private var selectedHourSteps: Int? = nil
    
    @State private var selectedIndexDistance: Int? = nil
    @State private var selectedHourDistance: Int? = nil
    
    @State private var selectedIndexCalories: Int? = nil
    @State private var selectedHourCalories: Int? = nil

    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: Steps chart
            ChartBox(title: "Steps", color: .orange) {
                
                if let time = ringManager.timeChartSteps {
                    HStack {
                        Text("\(String(ringManager.stepsValueChart ?? "__ - __"))")
                        Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                }

                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Steps", data.steps)
                        )
                        .foregroundStyle(.orange.gradient)
                        .cornerRadius(4)
                    }

                    if let selectedHourSteps {
                        RuleMark(x: .value("Selected", selectedHourSteps))
                            .foregroundStyle(.yellow)
                    }
                }
                .chartXScale(domain: 0...24)
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
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        let plotFrame = geo[proxy.plotAreaFrame]

                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let xInPlot = value.location.x - plotFrame.origin.x
                                        if let hour: Int = proxy.value(atX: xInPlot) {
                                            // allow dragging across whole x axis
                                            selectedHourSteps = min(max(hour, 0), 23)
                                        }
                                    }
                            )
                    }
                }
                .onChange(of: selectedHourSteps) { _, newHour in
                    guard let hour = newHour else { return }

                    // Look up data *if it exists* for that hour
                    if let selected = pedometerManager.hourlyData.first(where: { $0.hour == hour }) {
                        ringManager.stepsValueChart = "\(selected.steps)"
                        ringManager.timeChartSteps = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.prepare()
                        generator.impactOccurred()
                    } else {
                        // No data at this hour – optional placeholder handling
                        ringManager.stepsValueChart = "0"
                        ringManager.timeChartSteps = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }
            
            // MARK: Distance chart
            ChartBox(title: "Distance (m)", color: .blue) {
                
                if let time = ringManager.timeChartDistance {
                    HStack {
                        Text("\(String(ringManager.distanceValueChart ?? "__ - __"))")
                        Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                }
                
                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Distance", data.distance)
                        )
                        .foregroundStyle(.blue.gradient)
                        .cornerRadius(4)
                    }
                    
                    if let selectedHourDistance {
                        RuleMark(x: .value("Selected", selectedHourDistance))
                            .foregroundStyle(.yellow)
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
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        let plotFrame = geo[proxy.plotAreaFrame]

                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let xInPlot = value.location.x - plotFrame.origin.x
                                        if let hour: Int = proxy.value(atX: xInPlot) {
                                            // allow dragging across whole x axis
                                            selectedHourDistance = min(max(hour, 0), 23)
                                        }
                                    }
                            )
                    }
                }
                .onChange(of: selectedHourDistance) { _, newHour in
                    guard let hour = newHour else { return }

                    // Look up data *if it exists* for that hour
                    if let selected = pedometerManager.hourlyData.first(where: { $0.hour == hour }) {
                        ringManager.distanceValueChart = "\(selected.distance)"
                        ringManager.timeChartDistance = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.prepare()
                        generator.impactOccurred()
                    } else {
                        // No data at this hour – optional placeholder handling
                        ringManager.distanceValueChart = "0"
                        ringManager.timeChartDistance = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }

            // MARK: Calories chart
            ChartBox(title: "Calories (kcal)", color: .red) {
                
                if let time = ringManager.timeChartCalories {
                    HStack {
                        Text("\(String(ringManager.caloriesValueChart ?? "__ - __"))")
                        Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                }
                
                Chart {
                    ForEach(pedometerManager.hourlyData) { data in
                        BarMark(
                            x: .value("Hour", data.hour),
                            y: .value("Calories", data.calories)
                        )
                        .foregroundStyle(.red.gradient)
                        .cornerRadius(4)
                    }
                    
                    if let selectedHourCalories {
                        RuleMark(x: .value("Selected", selectedHourCalories))
                            .foregroundStyle(.yellow)
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
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        let plotFrame = geo[proxy.plotAreaFrame]

                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let xInPlot = value.location.x - plotFrame.origin.x
                                        if let hour: Int = proxy.value(atX: xInPlot) {
                                            // allow dragging across whole x axis
                                            selectedHourCalories = min(max(hour, 0), 23)
                                        }
                                    }
                            )
                    }
                }
                .onChange(of: selectedHourCalories) { _, newHour in
                    guard let hour = newHour else { return }

                    // Look up data *if it exists* for that hour
                    if let selected = pedometerManager.hourlyData.first(where: { $0.hour == hour }) {
                        ringManager.caloriesValueChart = "\(selected.calories)"
                        ringManager.timeChartCalories = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.prepare()
                        generator.impactOccurred()
                    } else {
                        // No data at this hour – optional placeholder handling
                        ringManager.caloriesValueChart = "0"
                        ringManager.timeChartCalories = dateFromSecondsSinceMidnight(Double(hour) * 3600)
                    }
                }
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }

            
        }
        .onDisappear() {
            selectedHourSteps = nil
            ringManager.stepsValueChart = nil
            ringManager.timeChartSteps = nil
            
            selectedHourDistance = nil
            ringManager.distanceValueChart = nil
            ringManager.timeChartDistance = nil
            
            selectedHourCalories = nil
            ringManager.caloriesValueChart = nil
            ringManager.timeChartCalories = nil
        }
    }
    
    func dateFromSecondsSinceMidnight(_ seconds: Double) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return startOfDay.addingTimeInterval(seconds)
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
