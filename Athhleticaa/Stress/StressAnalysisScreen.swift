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
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    
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
                // MARK: - Heart Rate Section
                VStack(spacing: 16) {
//                    Image("HeartRateIcon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .foregroundColor(.green)
//                        .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 0)

//                    Image(systemName: "heart.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 38, height: 38)
//                        .foregroundColor(.red)

                    Text("\(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0)")
                        .font(.system(size: 44, weight: .bold))

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
                
                
//                VStack(spacing: 16) {
//                    HStack {
//                        Text("Real-time stress")
//                            .font(.headline)
//                        Spacer()
//                        ZStack {
//                            Image(systemName: "leaf.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 28, height: 28)
//                                .foregroundColor(.green)
//                                .scaleEffect(animateHeart ? 1.3 : 1.0)
//                                .animation(
//                                    isMeasuring
//                                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
//                                    : .default,
//                                    value: animateHeart
//                                )
//                        }
//                        Text(currentHeartRate != nil ? "\(currentHeartRate!) bpm" : "-- bpm")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//                    }
//
//                    Button(action: {
//                        if !isMeasuring {
//                            // Start measuring
//                            isMeasuring = true
//                            currentHeartRate = nil
//                            ringManager.measureHeartRate()
//                            animateHeart = true
//                        } else {
//                            // Stop measuring
//                            isMeasuring = false
//                            currentHeartRate = nil
//                            animateHeart = false
//                        }
//                    }) {
//                        Text(isMeasuring ? "Measuring..." : "Click to start measurement")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isMeasuring ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                    .disabled(isMeasuring) // prevent rapid taps
//                }
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
//                .cornerRadius(16)
//                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                
                
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
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Stress").font(.headline)
            }
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
            Text(title)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }
}
