//
//  ECGScreenViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/03/26.
//

import SwiftUI

struct ECGScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    @State private var showCalendar = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    
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
                        Text(ringManagerPro.selectedDate, formatter: dateFormatter)
                            .font(.headline)
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
                    .sheet(isPresented: $showCalendar) {
                        WeeklyCalendarViewPro(ringManagerPro: ringManagerPro, fromScreen: "HRVScreenPro")
                            .presentationDetents([.height(500)]) // Only as tall as needed
                            .presentationDragIndicator(.visible)
                    }
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("ECG test")
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
                    
                    if let currentData = ringManagerPro.vpECGTestDataModel {
                        ECGWaveformView(ecgData: currentData)
                            .frame(height: 200)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding()
                          
                        Text("Duration: \(currentData.duration ?? "0")s")
                        Text("Heart Rate: \(currentData.aveHeart ?? "--") bpm")
                        Text("HRV: \(currentData.aveHrv ?? "--")")
                        Text("QRT: \(currentData.aveQT ?? "--")")
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(Text("No ECG data"))
                    }
                    
                    if let currentData = ringManagerPro.vpttTestModel {
                          
//                        Text("Duration: \(currentData.duration ?? "0")s")
                        Text("Heart Rate: \(currentData.heart) bpm")
                        Text("HRV: \(currentData.hrv)")
                        Text("QRT: \(currentData.qt)")
                    }

                    Button(action: {
                        if ringManagerPro.connectedPeripheral != nil {
                            // Start measurement
                            ringManagerPro.ecgManagerPro.startECGTest(ringManagerPro: ringManagerPro)
                            // Cancel any existing timer
                            
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
                
            }
            .padding()
            .padding(.bottom, 100)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("HRV").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
