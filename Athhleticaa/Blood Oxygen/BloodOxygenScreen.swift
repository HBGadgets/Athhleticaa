//
//  BloodOxygenDetailsScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/11/25.
//

import SwiftUI

struct BloodOxygenScreenView: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @ObservedObject var bloodOxygenManager: BloodOxygenManager
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
        case 0..<29:
            return "Low"
        case 30..<59:
            return "Normal"
        case 60..<79:
            return "Normal"
        default:
            return "High"
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
                        WeeklyCalendarView(ringManager: ringManager, fromScreen: "BloodOxygenScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
                MonitoringItem(
                    title: "SPO2 Detection",
                    subtitle: "Monitor once every hour",
                    isEnabled: $ringManager.spo2Monitoring
                ) {
                    ringManager.setBloodOxygenSchedule(enabled: ringManager.spo2Monitoring)
                }
                Image(systemName: "lungs.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 120)
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.5), radius: 15, x: 0, y: 0)
                // MARK: - Blood Oxygen Rate Section
                if let lastNonZeroBO = ringManager.bloodOxygenManager.lastNonZeroBloodOxygenReading {
                    if let time = ringManager.timeChartBloodOxygen {
                        HStack {
                            Text("\(String(ringManager.spo2ValueChart ?? "__ - __"))")
                            Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                    } else {
                        HStack {
                            Text("\(String(format: "%.0f", lastNonZeroBO.minSoa2))% - \(String(format: "%.0f", lastNonZeroBO.maxSoa2))%")
                            Text(lastNonZeroBO.date, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                    }
                    BloodOxygenDotChart(data: ringManager.bloodOxygenManager.readings, ringManager: ringManager)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                        .frame(height: 250)
                } else {
                    Text("No data")
                }

                // MARK: - Average / Min / Max
                if let day = ringManager.bloodOxygenManager.readings.first {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(Int(ringManager.bloodOxygenManager.averageBloodOxygen))")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(Int(ringManager.bloodOxygenManager.minBloodOxygen))")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(Int(ringManager.bloodOxygenManager.maxBloodOxygen))")
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
                
                
                NavigationLink(destination: BloodOxygenDataDetailScreenView(ringManager: ringManager)) {
                    HStack {
                        Text("Data details")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                        Spacer()
                        HStack(spacing: 4) {
                            Text({
                                if let data = ringManager.bloodOxygenManager.lastNonZeroBloodOxygenReading,
                                   let index = ringManager.bloodOxygenManager.lastNonZeroBloodOxygenIndex,
                                   let date = ringManager.bloodOxygenManager.lastNonZeroBloodOxygenReading?.date {
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
            }
            .padding()
            .padding(.bottom, 100)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Blood Oxygen").font(.headline)
            }
        }
        .onAppear() {
            ringManager.bloodOxygenManager.fetchBloodOxygenData()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
