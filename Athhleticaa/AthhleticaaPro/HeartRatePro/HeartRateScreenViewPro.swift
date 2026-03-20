//
//  HeartRateScreenViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 07/03/26.
//

import SwiftUI

struct HeartRateScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @ObservedObject var detailDataManager: DetailDataManagerPro
    @State private var isMeasuring = false
    @State private var animateHeart = false
    @State private var showCalendar = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    @State private var goToInfoScreen = false
    @State private var stopWorkItem: DispatchWorkItem?
    
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
                        Text(ringManagerPro.selectedDate, formatter: dateFormatter)
                            .font(.headline)
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
                    .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    .sheet(isPresented: $showCalendar) {
                        WeeklyCalendarViewPro(ringManagerPro: ringManagerPro, fromScreen: "HeartRateScreen")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
//                MonitoringItem(
//                    title: "Full day Heart Rate",
//                    subtitle: "Monitor once every 10 minutes",
//                    isEnabled: $ringManagerPro.heartRateMonitoring
//                ) {
//                    ringManager.setHeartRateSchedule(enabled: ringManager.heartRateMonitoring)
//                }
                VStack(spacing: 16) {
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
                    
                    if let heartRate = ringManagerPro.dashboardDetailsData?.last?.heartRate {
                        Text("\(ringManagerPro.dashboardDetailsData?.last?.heartRate ?? 0)")
                            .font(.system(size: 44, weight: .bold))
                            .fontWidth(.expanded)

                        Text("BPM")
                            .font(.subheadline)
                    } else {
                        Text("No data yet")
                            .fontWidth(.expanded)
                    }
                    
                }

                // MARK: - Average / Min / Max
                if let day = ringManagerPro.dashboardDetailsData?.first?.heartRate {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(ringManagerPro.dashboardRawHealthDataStats?.heart?.avg ?? 0)")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(ringManagerPro.dashboardRawHealthDataStats?.heart?.min ?? 0)")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(ringManagerPro.dashboardRawHealthDataStats?.heart?.max ?? 0)")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "--")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "--")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "--")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                }
                
                
//                NavigationLink(destination: HeartRateDataDetailScreenView(ringManager: ringManager)) {
//                    HStack {
//                        Text("Data details")
//                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
//                        Spacer()
//                        HStack(spacing: 4) {
//                            Text({
//                                if let data = ringManagerPro.dashboardDetailsData,
//                                   let time = ringManagerPro.dashboardDetailsData?.last?.time {
//                                   return time.toAMPM
//                                } else {
//                                    return "--:--"
//                                }
//                            }())
//                            Image(systemName: "chevron.right")
//                        }
//                        .foregroundStyle(.gray)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
//                    .cornerRadius(16)
//                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
//                }
                
                
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
                        Text(ringManagerPro.heartRate != nil ? "\(ringManagerPro.heartRate!) bpm" : "-- bpm")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        if ringManagerPro.connectedPeripheral != nil {
                            // Start measurement
                            ringManagerPro.heartRateManager.readLiveHeartRate(ringManagerPro: ringManagerPro)
                            
                            // Cancel any existing timer
                            stopWorkItem?.cancel()
                            
                            // Create new stop task
                            let workItem = DispatchWorkItem {
                                ringManagerPro.heartRateManager.stopLiveHeartRate()
                                
                                // also reset UI (important fallback)
                                isMeasuring = false
                                animateHeart = false
                            }
                            
                            stopWorkItem = workItem
                            
                            // Execute after 30 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: workItem)
                        } else {
                            showNavigationError = true
                        }
                    }) {
                        Text(isMeasuring ? "Measuring..." : "Tap to start measurement")
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
                
                
                if let dataList = ringManagerPro.dashboardDetailsData {
                                    
                    if let time = ringManagerPro.timeChartHeartRate {
                        HStack {
                            if let hb = ringManagerPro.heartRateValueChart {
                                Text("\(hb) BPM")
                            }
                            Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    } else {
                        HStack {
                            Text("\(ringManagerPro.dashboardDetailsData?.last?.heartRate ?? 0) BPM")
                            Text({
                                if let data = ringManagerPro.dashboardDetailsData,
                                   let time = ringManagerPro.dashboardDetailsData?.last?.time {
                                   return time.toAMPM
                                } else {
                                    return "--:--"
                                }
                            }())
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    }
                    HeartRateHealthChartViewPro(
                        data: ringManagerPro.dashboardDetailsData ?? [],
                        ringManagerPro: ringManagerPro
                    )
                    .padding(10)
                    .frame(maxWidth: .infinity, minHeight: 250)
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
        .navigationDestination(isPresented: $goToScanScreen) {
            ScanningScreenPro()
        }
        .alert("Ring not connected", isPresented: $showNavigationError) {
            Button("Cancel", role: .cancel) {}
            Button("Scan for ring") {
                goToScanScreen = true
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Connect the app with ring first")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Heart rate").font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    goToInfoScreen = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                }
            }
        }
        .onChange(of: ringManagerPro.heartRateTestState) { oldValue, newValue in
            guard let state = newValue else { return }

            switch state {
            case .start, .testing:
                isMeasuring = true
                animateHeart = false
                DispatchQueue.main.async {
                    animateHeart = true
                }

            case .notWear, .deviceBusy:
                isMeasuring = false
                animateHeart = false

            case .over:
                isMeasuring = false
                animateHeart = false

            @unknown default:
                isMeasuring = false
                animateHeart = false
            }
        }
        .onAppear() {
            ringManagerPro.detailDataManager.readDetailDataByDay(day: 0) { result in
                print("done")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToInfoScreen) {
            HeartRateInfoScreen()
        }
    }
}


extension String {
    var toAMPM: String {
        let parts = self.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return self }
        let suffix = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, suffix)
    }
}


