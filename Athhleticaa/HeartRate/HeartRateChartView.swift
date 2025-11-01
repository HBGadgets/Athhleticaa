//
//  HeartRateHistoryView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI
import Charts

struct HeartRatePoint: Identifiable, Hashable {
    let id = UUID()
    let bpm: Double
    let timeLabel: String
    let date: String
}

extension QCSchedualHeartRateModel {
    func toHeartRatePoints() -> [HeartRatePoint] {
        // Generate random fallback data between 80–110 for 24 hours
        var points: [HeartRatePoint] = (0..<24).map { hour in
            let time = String(format: "%02d:00", hour)
            let bpm = Double(Int.random(in: 80...110))
            return HeartRatePoint(bpm: bpm, timeLabel: time, date: date)
        }

        // If SDK has actual heart rate data, override the random data
        if let rates = heartRates as? [NSNumber], !rates.isEmpty {
            points = rates.enumerated().map { index, value in
                let hour = index % 24
                let time = String(format: "%02d:00", hour)
                return HeartRatePoint(
                    bpm: value.doubleValue,
                    timeLabel: time,
                    date: date
                )
            }
        }

        return points
    }
}


//struct HeartRateChartView: View {
//    @State private var selectedTab = "Day"
//    @State private var selectedPoint: HeartRatePoint? = nil
//    @ObservedObject var manager: HeartRateManager   // 👈 Injected from parent
//
//    let tabs = ["Day", "Week", "Month"]
//
//    // MARK: - Map QCSchedualHeartRateModel → HeartRatePoint
//    private func mapToHeartRatePoints(_ models: [QCSchedualHeartRateModel], type: HeartRateManager.DataType) -> [HeartRatePoint] {
//        switch type {
//        case .day:
//            return models.flatMap { $0.toHeartRatePoints() }
//        case .week:
//            let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
//            return models.enumerated().map { index, model in
//                let avg = average(of: model.toHeartRatePoints().map(\.bpm))
//                return HeartRatePoint(bpm: avg,
//                                      timeLabel: weekDays[safe: index] ?? "Day\(index)",
//                                      date: model.date)
//            }
//        case .month:
//            return models.enumerated().map { index, model in
//                let avg = average(of: model.toHeartRatePoints().map(\.bpm))
//                return HeartRatePoint(bpm: avg,
//                                      timeLabel: "\(index + 1)",
//                                      date: model.date)
//            }
//        }
//    }
//
//    // MARK: - Current dataset based on selected tab
//    var currentData: [HeartRatePoint] {
//        switch selectedTab {
//        case "Week": return mapToHeartRatePoints(manager.weekData, type: .week)
//        case "Month": return mapToHeartRatePoints(manager.monthData, type: .month)
//        default: return mapToHeartRatePoints(manager.dayData, type: .day)
//        }
//    }
//
//    // MARK: - View
//    var body: some View {
//        VStack(spacing: 24) {
//            
//            // Tabs
//            HStack {
//                ForEach(tabs, id: \.self) { tab in
//                    Button {
//                        withAnimation(.spring()) {
//                            selectedTab = tab
//                            selectedPoint = nil
//                            loadData(for: tab)
//                        }
//                    } label: {
//                        Text(tab)
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(selectedTab == tab ? .white : .gray)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(
//                                Capsule()
//                                    .fill(selectedTab == tab ? Color.black : Color.clear)
//                            )
//                    }
//                }
//            }
//
//            if manager.isLoading {
//                ProgressView("Loading...")
//                    .padding(.top, 40)
//            } else if let error = manager.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//            } else {
//                // Current BPM Display
//                VStack(spacing: 4) {
//                    Text("\(Int(selectedPoint?.bpm ?? currentData.last?.bpm ?? 0))")
//                        .font(.system(size: 42, weight: .bold))
//                        .foregroundColor(.black)
//
//                    Text("bpm")
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//
//                    if let selected = selectedPoint {
//                        Text(selected.timeLabel)
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                            .transition(.opacity)
//                    }
//                }
//                
//                Chart {
//                    ForEach(currentData) { point in
//                        LineMark(
//                            x: .value("Time", point.time),
//                            y: .value("Value", point.value)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(Color.red)
//                        
//                        AreaMark(
//                            x: .value("Time", point.time),
//                            y: .value("Value", point.value)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [Color.red.opacity(0.25), .clear],
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                    }
//                    
//                    if let selected = selectedPoint {
//                        RuleMark(x: .value("Selected", selected.time))
//                            .lineStyle(StrokeStyle(lineWidth: 1))
//                            .foregroundStyle(Color.red)
//                            .annotation(position: .top) {
//                                Circle()
//                                    .fill(Color.red.opacity(0.6))
//                                    .frame(width: 10, height: 10)
//                            }
//                    }
//                }
//                .chartYScale(domain: 40...140)
//                .frame(height: 200)
//                .padding(.horizontal)
//                .chartOverlay { proxy in
//                    GeometryReader { geo in
//                        Rectangle()
//                            .fill(Color.clear)
//                            .contentShape(Rectangle())
//                            .gesture(
//                                DragGesture(minimumDistance: 0)
//                                    .onChanged { value in
//                                        let xPosition = value.location.x - geo[proxy.plotAreaFrame].origin.x
//                                        if let time: String = proxy.value(atX: xPosition) {
//                                            if let nearest = currentData.min(by: {
//                                                abs(timeAsDouble($0.time) - timeAsDouble(time))
//                                                < abs(timeAsDouble($1.time) - timeAsDouble(time))
//                                            }) {
//                                                withAnimation(.easeInOut(duration: 0.1)) {
//                                                    selectedPoint = nearest
//                                                }
//                                            }
//                                        }
//                                    }
//                                    .onEnded { _ in }
//                            )
//                    }
//                }
//
//                // Chart
//                Chart {
//                    ForEach(currentData) { point in
//                        LineMark(
//                            x: .value("Time", point.timeLabel),
//                            y: .value("BPM", point.bpm)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(Color.red)
//
//                        AreaMark(
//                            x: .value("Time", point.timeLabel),
//                            y: .value("BPM", point.bpm)
//                        )
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [Color.red.opacity(0.25), .clear],
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                    }
//
//                    if let selected = selectedPoint {
//                        RuleMark(x: .value("Selected", selected.timeLabel))
//                            .lineStyle(StrokeStyle(lineWidth: 1))
//                            .foregroundStyle(Color.red)
//                            .annotation(position: .top) {
//                                Circle()
//                                    .fill(Color.red.opacity(0.6))
//                                    .frame(width: 10, height: 10)
//                            }
//                    }
//                }
//                .chartYScale(domain: 40...140)
//                .frame(height: 200)
//                .padding(.horizontal)
//                .chartOverlay { proxy in
//                    GeometryReader { geo in
//                        Rectangle()
//                            .fill(Color.clear)
//                            .contentShape(Rectangle())
//                            .gesture(
//                                DragGesture(minimumDistance: 0)
//                                    .onChanged { value in
//                                        let xPos = value.location.x - geo[proxy.plotAreaFrame].origin.x
//                                        if let time: String = proxy.value(atX: xPos) {
//                                            if let nearest = currentData.min(by: {
//                                                abs(timeAsDouble($0.timeLabel) - timeAsDouble(time)) <
//                                                abs(timeAsDouble($1.timeLabel) - timeAsDouble(time))
//                                            }) {
//                                                withAnimation(.easeInOut(duration: 0.1)) {
//                                                    selectedPoint = nearest
//                                                }
//                                            }
//                                        }
//                                    }
//                            )
//                    }
//                }
//
//                // Stats
//                HStack(spacing: 40) {
//                    StatView(title: "Average", value: "\(Int(average(of: currentData.map(\.bpm))))")
//                    StatView(title: "Min", value: "\(Int(currentData.map(\.bpm).min() ?? 0))")
//                    StatView(title: "Max", value: "\(Int(currentData.map(\.bpm).max() ?? 0))")
//                }
//            }
//        }
//        .padding()
//        .onAppear { loadData(for: selectedTab) }
//    }
//
//    // MARK: - Helpers
//    private func loadData(for tab: String) {
//        switch tab {
//        case "Week": manager.fetchWeeklyHeartRate()
//        case "Month": manager.fetchMonthlyHeartRate()
//        default: manager.fetchTodayHeartRate()
//        }
//    }
//
//    private func timeAsDouble(_ time: String) -> Double {
//        if let val = Double(time) { return val }
//        let comps = time.split(separator: "h").compactMap { Double($0) }
//        return comps.first ?? 0 + ((comps.last ?? 0) / 60)
//    }
//
//    private func average(of data: [Double]) -> Double {
//        guard !data.isEmpty else { return 0 }
//        return data.reduce(0, +) / Double(data.count)
//    }
//}
//
//// MARK: - Safe Index Helper
//extension Collection {
//    subscript(safe index: Index) -> Element? {
//        indices.contains(index) ? self[index] : nil
//    }
//}
