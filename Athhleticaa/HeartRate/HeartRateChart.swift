//
//  HeartRateChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI
import Charts

struct HeartRateChart: View {
    @State private var selectedTab = "Day"
    @State private var selectedPoint: HRVDataPoint? = nil
    @StateObject var heartRateManager = HeartRateManager()
    
    let tabs = ["Day", "Week", "Month"]
    
    // Different datasets for each tab
    let dayData: [HRVDataPoint] = (1...24).map { hour in
        let time = String(format: "%02d:00", hour)
        let value = Double(Int.random(in: 80...110))
        return HRVDataPoint(time: time, value: value)
    }
    
    let weekData: [HRVDataPoint] = [
        .init(time: "Mon", value: 0),
        .init(time: "Tue", value: 0),
        .init(time: "Wed", value: 0),
        .init(time: "Thu", value: 0),
        .init(time: "Fri", value: 0),
        .init(time: "Sat", value: 0),
        .init(time: "Sun", value: 0)
    ]
    
    let monthData: [HRVDataPoint] = [
        .init(time: "1", value: 0),
        .init(time: "5", value: 0),
        .init(time: "10", value: 0),
        .init(time: "15", value: 0),
        .init(time: "20", value: 0),
        .init(time: "25", value: 0),
        .init(time: "30", value: 0)
    ]
    
    // Helper to get current dataset based on selected tab
    var currentData: [HRVDataPoint] {
        switch selectedTab {
        case "Week": return weekData
        case "Month": return monthData
        default: return dayData
        }
    }
    
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: Tabs
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = tab
                            selectedPoint = nil
                        }
                        switch tab {
                            case "Day":
                                heartRateManager.fetchTodayHeartRate()
                            case "Week":
                                heartRateManager.fetchWeeklyHeartRate()
                            case "Month":
                                heartRateManager.fetchMonthlyHeartRate()
                            default:
                                break
                        }
                    }) {
                        Text(tab)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTab == tab ? Color.black : Color.clear)
                            )
                    }
                }
            }
            .onAppear {
                // Fetch day data on initial load
                heartRateManager.fetchTodayHeartRate()
            }
            
            // MARK: HRV Value + Time Display
            VStack(spacing: 4) {
                Text("\(Int(selectedPoint?.value ?? currentData.last?.value ?? 0))")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.black)
                
                Text("pm")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                if let selected = selectedPoint {
                    Text(selected.time)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
//            .animation(.easeInOut, value: selectedPoint)
            
            // MARK: Chart
            Chart {
                ForEach(currentData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.red)
                    
                    AreaMark(
                        x: .value("Time", point.time),
                        y: .value("Value", point.value)
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
                
                if let selected = selectedPoint {
                    RuleMark(x: .value("Selected", selected.time))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color.red)
                        .annotation(position: .top) {
                            Circle()
                                .fill(Color.red.opacity(0.6))
                                .frame(width: 10, height: 10)
                        }
                }
            }
            .chartYScale(domain: 40...140)
            .frame(height: 200)
            .padding(.horizontal)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let xPosition = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                    if let time: String = proxy.value(atX: xPosition) {
                                        if let nearest = currentData.min(by: {
                                            abs(timeAsDouble($0.time) - timeAsDouble(time))
                                            < abs(timeAsDouble($1.time) - timeAsDouble(time))
                                        }) {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                selectedPoint = nearest
                                            }
                                        }
                                    }
                                }
                                .onEnded { _ in }
                        )
                }
            }
            
            // MARK: Stats
            HStack(spacing: 40) {
                StatView(title: "Average", value: "\(Int(average(of: currentData)))")
                StatView(title: "Minimum", value: "\(Int(minValue(of: currentData)))")
                StatView(title: "Maximum", value: "\(Int(maxValue(of: currentData)))")
            }
            .padding(.bottom, 16)
        }
        .padding()
    }
    
    // MARK: Helpers
    private func timeAsDouble(_ time: String) -> Double {
        if let val = Double(time) { return val } // For month labels
        let comps = time.split(separator: ":").compactMap { Double($0) }
        return comps.first ?? 0 + ((comps.last ?? 0) / 60)
    }
    
    private func average(of data: [HRVDataPoint]) -> Double {
        data.map(\.value).reduce(0, +) / Double(data.count)
    }
    
    private func minValue(of data: [HRVDataPoint]) -> Double {
        data.map(\.value).min() ?? 0
    }
    
    private func maxValue(of data: [HRVDataPoint]) -> Double {
        data.map(\.value).max() ?? 0
    }
}
