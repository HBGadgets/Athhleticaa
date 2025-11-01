//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI

import SwiftUI
import Charts

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManager = QCCentralManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if ringManager.dataLoaded == true {
                        ScrollView {
                            VStack(spacing: 16) {
                                
                                
                                // MARK: - Heart Rate
                                HStack {
                                    NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
                                        HeartRateCard(bpm: ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)
                                    }
                                    BatteryCard(charge: ringManager.batteryLevel ?? 0)
                                }

                                // MARK: - Steps
                                StepsCard(
                                    calories: ringManager.pedometerManager.stepsData?.calories ?? 0,
                                    steps: ringManager.pedometerManager.stepsData?.totalSteps ?? 0,
                                    distance: Double(ringManager.pedometerManager.stepsData?.distance ?? 0) / 1000
                                )

                                // MARK: - Battery and Sleep
//                                HStack(spacing: 16) {
//                                    BatteryCard(charge: ringManager.batteryLevel ?? 0)
//                                    SleepCard(hours: 6, minutes: 38)
//                                }
                                
                                
                                SleepCard(hours: 6, minutes: 38)

                                // MARK: - Achievements
                                StressCard(
                                    lastStress: Double(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0),
                                    averageStress: ringManager.stressManager.averageStress,
                                    rangeMin: ringManager.stressManager.rangeMin,
                                    rangeMax: ringManager.stressManager.rangeMax
                                )
                            }
                            .padding()
                            .padding(.bottom, 70)
                        }
                    } else {
                        VStack(spacing: 20) {
                            ProgressView("Connecting to your device…")
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                            Text("Please wait while we connect to your ring.")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray6))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        colorScheme == .dark ?
                        Image(.athhleticaaLogoDarkMode)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                        :
                        Image(.athhleticaaLogoLightMode)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                }.navigationBarTitleDisplayMode(.inline)
                
                VStack {
                    Spacer()
                    TabBar()
                        .padding(.bottom, -10)
                }
            }
            
        }
    }
    
}

struct TabBar: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<4) { index in
                tabButton(for: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }

    @ViewBuilder
    func tabButton(for index: Int) -> some View {
        let icons = ["house.fill", "moon.fill", "heart.fill", "person.crop.circle"]
        let isSelected = selectedTab == index

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = index
            }
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                colorScheme == .dark ?
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                :
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black)
            }
        }
    }
}

