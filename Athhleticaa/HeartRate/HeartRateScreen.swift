//
//  HeartRateScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI

struct HeartRateScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @ObservedObject var heartRateManager: HeartRateManager
    @State private var isMeasuring = false
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
                // MARK: - Heart Rate Section
                HStack {
                    Button(action: {
                        showCalendar.toggle()
                    }) {
                        Text(ringManager.selectedDate, formatter: dateFormatter)
                            .font(.headline)
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
                    .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    .sheet(isPresented: $showCalendar) {
                        WeeklyCalendarView(ringManager: ringManager, fromScreen: "HeartRateScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
                VStack(spacing: 16) {
//                    Image("HeartRateIcon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
                    Image(systemName: "waveform.path.ecg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 0)

                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundColor(.red)

                    Text("\(ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)")
                        .font(.system(size: 44, weight: .bold))
                        .fontWidth(.expanded)

                    Text("BPM")
                        .font(.subheadline)
                }

                // MARK: - Average / Min / Max
                if let day = ringManager.heartRateManager.dayData.first {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(day.averageHeartRate)")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(day.minHeartRate)")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(day.maxHeartRate)")
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
                
                
                NavigationLink(destination: HeartRateDataDetailScreenView(ringManager: ringManager)) {
                    HStack {
                        Text("Data details")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                        Spacer()
                        HStack(spacing: 4) {
                            Text({
                                if let data = ringManager.heartRateManager.dayData.first,
                                   let index = data.lastNonZeroHeartRateIndex,
                                   let date = data.timeForHeartRate(at: index) {
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
                
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Real-time heart rate")
                            .font(.headline)
                        Spacer()
                        ZStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.red)
                                .scaleEffect(animateHeart ? 1.3 : 1.0)
                                .animation(
                                    isMeasuring
                                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                    : .default,
                                    value: animateHeart
                                )
                        }
                        Text(ringManager.heartRateManager.heartRate != nil ? "\(ringManager.heartRateManager.heartRate!) bpm" : "-- bpm")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        if !isMeasuring {
                            // Start measuring
                            isMeasuring = true
                            ringManager.heartRateManager.heartRate = nil
                            ringManager.heartRateManager.measureHeartRate() {
                                isMeasuring = false
                                animateHeart = false
                            }
    //                        ringManager.measureHeartRate()
                            animateHeart = true
                        } else {
                            // Stop measuring
                            isMeasuring = false
                            ringManager.heartRateManager.heartRate = nil
                            animateHeart = false
                        }
                    }) {
                        Text(isMeasuring ? "Measuring..." : "Click to start measurement")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isMeasuring ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .disabled(isMeasuring) // prevent rapid taps
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                
                
                if let day = ringManager.heartRateManager.dayData.first {
                    HeartRateChartView(heartRateData: day)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                        .frame(height: 250)
                } else {
                    Text("No data")
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Heart rate").font(.headline)
            }
        }
        .onAppear() {
            ringManager.heartRateManager.fetchTodayHeartRate()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
