//
//  ContentView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/10/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManager = QCCentralManager()
    @State private var showAlert = false
    @State private var timeoutTask: Task<Void, Never>? = nil
    
    private func startTimeout() {
        cancelTimeout()
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 7 * 1_000_000_000)
            // Only show alert if data not loaded and ring not connected
            if !ringManager.dataLoaded && ringManager.connectedPeripheral == nil {
                await MainActor.run {
                    showAlert = true
                }
            }
        }
    }

    private func cancelTimeout() {
        timeoutTask?.cancel()
        timeoutTask = nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch ringManager.selectedTab {
                    case 0:
                        DashboardView(ringManager: ringManager)
                    case 1:
                        HeartRateScreenView(ringManager: ringManager, heartRateManager: ringManager.heartRateManager)
                    case 2:
                        ActivityScreenView(ringManager: ringManager, pedometerManager: ringManager.pedometerManager)
                    case 3:
                        SleepsAnalysisScreenView(sleepManager: ringManager.sleepManager, ringManager: ringManager)
                    case 4:
                        DeviceInfoView(ringManager: ringManager)
//                    case 5:
//                        StressAnalysisScreenView(ringManager: ringManager, stressManager: ringManager.stressManager)
                    default:
                        DashboardView(ringManager: ringManager)
                    }
                }
                VStack {
                    Spacer()
                    TabBar(ringManager: ringManager)
                        .padding(.bottom, -10)
                }
                if !ringManager.dataLoaded && (ringManager.connectedPeripheral != nil) {
                    VStack(spacing: 20) {
                        ProgressView("Syncing data")
                            .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                            .scaleEffect(1.2)
                        Text("Please wait...")
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .onAppear {
                        startTimeout()
                    }
                    .onDisappear {
                        cancelTimeout()
                    }
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
            }
        }
        .onAppear {
            ringManager.selectedTheme = (colorScheme == .dark) ? .dark : .light
         }
        .alert(
            "Couldn't get data",
            isPresented: $showAlert, // must be a Binding<Bool>
            actions: {
                Button("OK", role: .cancel) { }
            },
            message: {
                Text("Please make sure the ring is binded and accessible to the phone")
            }
        )
    }
}
