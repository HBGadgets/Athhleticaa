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
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showCalendar) {
                        WeeklyCalendarView(ringManager: ringManager, fromScreen: "BloodOxygenScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                }
                // MARK: - Heart Rate Section
                if let day = ringManager.bloodOxygenManager.readings.first {
                    BloodOxygenDotChart(data: ringManager.bloodOxygenManager.readings)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
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
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Blood Oxygen").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
