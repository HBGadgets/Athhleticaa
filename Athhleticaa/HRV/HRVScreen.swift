//
//  HRVScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUICore

import SwiftUI
import Charts

struct HRVScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @ObservedObject var hrvManager: HRVManager
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
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
                        WeeklyCalendarView(ringManager: ringManager, fromScreen: "HRVScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                }
                // MARK: - Heart Rate Section
                HRVChartView(data: ringManager.hrvManager.hrvData ?? HRVModel(date: "0", values: [0], interval: 0))

                // MARK: - Average / Min / Max
                if let day = ringManager.hrvManager.hrvData {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(day.averageHRV)")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(day.minHRV)")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(day.maxHRV)")
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
                
                
                NavigationLink(destination: HRVDataDetailScreenView(ringManager: ringManager)) {
                    HStack {
                        Text("Data details")
                        Spacer()
                        HStack(spacing: 4) {
                            Text({
                                if let data = ringManager.hrvManager.hrvData?.validHRV,
                                   let index = hrvManager.hrvData?.lastNonZeroHRVIndex,
                                   let date = hrvManager.hrvData?.timeForHRVRate(at: index) {
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
                Text("HRV").font(.headline)
            }
        }
        .onAppear() {
            ringManager.hrvManager.fetchHRV()
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
