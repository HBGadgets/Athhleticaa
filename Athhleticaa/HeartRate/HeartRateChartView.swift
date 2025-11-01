//
//  HeartRateHistoryView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    @StateObject var manager = HeartRateManager()
    @State private var selectedTab = "Day"
    @State private var selectedPoint: HRVDataPoint? = nil
    
    private let tabs = ["Day", "Week", "Month"]
    
    // MARK: Pick data based on tab
    var currentData: [HRVDataPoint] {
        switch selectedTab {
        case "Week": return manager.weekData
        case "Month": return manager.monthData
        default: return manager.dayData
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
                            fetchData(for: tab)
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
            
            if currentData.isEmpty {
                ProgressView("Loading \(selectedTab.lowercased()) data...")
                    .onAppear {
                        fetchData(for: selectedTab)
                    }
            } else {
                // MARK: HR Value Display
                VStack(spacing: 4) {
                    Text("\(Int(selectedPoint?.value ?? currentData.last?.value ?? 0))")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("bpm")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    if let selected = selectedPoint {
                        Text(selected.time)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // MARK: Chart
                Chart {
                    ForEach(currentData) { point in
                        LineMark(
                            x: .value("Time", point.time),
                            y: .value("Heart Rate", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                        
                        AreaMark(
                            x: .value("Time", point.time),
                            y: .value("Heart Rate", point.value)
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
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                            }
                    }
                }
                .chartYScale(domain: 40...180)
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
                            )
                    }
                }
                
                // MARK: Stats
                HStack(spacing: 40) {
                    StatView(title: "Avg", value: "\(Int(average(of: currentData)))")
                    StatView(title: "Min", value: "\(Int(minValue(of: currentData)))")
                    StatView(title: "Max", value: "\(Int(maxValue(of: currentData)))")
                }
            }
        }
        .padding()
    }
    
    private func fetchData(for tab: String) {
        switch tab {
        case "Week": manager.fetchWeekData()
        case "Month": manager.fetchMonthData()
        default: manager.fetchDayData()
        }
    }
}
