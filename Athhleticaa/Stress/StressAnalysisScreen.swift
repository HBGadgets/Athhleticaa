//
//  StressAnalysisScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI

struct StressAnalysisScreenView: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @ObservedObject var stressManager: StressManager
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }
    
    private func levelString(stress: Int) -> String {
        switch stress {
        case 0...29: return "Low"
        case 30...59: return "Normal"
        default: return "High"
        }
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        showCalendar.toggle()
                    }) {
                        Text(ringManager.selectedDate, formatter: dateFormatter)
                            .font(.headline)
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
                    .sheet(isPresented: $showCalendar) {
                        WeeklyCalendarView(ringManager: ringManager, fromScreen: "StressAnalysisScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
                MonitoringItem(
                    title: "Full day stress Monitoring",
                    subtitle: "Monitor every 30 minutes",
                    isEnabled: $ringManager.stressMonitoring
                ) {
                    ringManager.setStressSchedule(enabled: ringManager.stressMonitoring)
                }
                // MARK: - Stress Section
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .foregroundColor(.green)
//                        .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 0)

                    Text("\(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0)")
                        .font(.system(size: 44, weight: .bold))
                        .fontWidth(.expanded)

                    Text("\(String(describing: levelString(stress: ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0)))")
                        .font(.subheadline)
                }

                // MARK: - Average / Min / Max
                if let day = ringManager.stressManager.stressData.first {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(day.averageStress)")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(day.minStress)")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(day.maxStress)")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "0")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "0")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "0")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                }
                
                
                NavigationLink(destination: StressDataDetailScreenView(ringManager: ringManager)) {
                    HStack {
                        Text("Data details")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                        Spacer()
                        HStack(spacing: 4) {
                            Text({
                                if let data = ringManager.stressManager.stressData.first,
                                   let index = data.lastNonZeroStressIndex,
                                   let date = data.timeForStressRate(at: index) {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "h:mm a"
                                    return formatter.string(from: date)
                                } else {
                                    return "--:--"
                                }
                            }())
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                }
                if let day = ringManager.stressManager.stressData.first {
                    StressChartView(stressData: day)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    Text("No data")
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Stress").font(.headline)
            }
        }
        .onAppear() {
            ringManager.stressManager.fetchStressData()
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

// MARK: - Reusable Components
struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWidth(.expanded)
            Text(title)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }
}
