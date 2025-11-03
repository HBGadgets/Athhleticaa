//
//  ContentView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/10/25.
//

import SwiftUI

import SwiftUI
import CoreBluetooth

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManager = QCCentralManager()
    @StateObject var sleepManager = SleepManager()
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
                        DashboardView(ringManager: ringManager, sleepManager: sleepManager)
                    case 1:
                        HeartRateScreenView(ringManager: ringManager)
                    case 2:
                        ActivityScreenView()
                    case 3:
                        SleepsAnalysisScreenView(sleepManager: sleepManager)
                    case 4:
                        StressAnalysisScreenView()
                    case 5:
                        ProfileView(ringManager: ringManager)
                    default:
                        DashboardView(ringManager: ringManager, sleepManager: sleepManager)
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
                }
            }
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
