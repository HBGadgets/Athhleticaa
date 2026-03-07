//
//  ContentViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 06/03/26.
//

import SwiftUI
import CoreBluetooth

struct ContentViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManagerPro = RingManagerPro()
//    @State private var showAlert = false
//    @State private var timeoutTask: Task<Void, Never>? = nil
    
//    private func startTimeout() {
//        cancelTimeout()
//        timeoutTask = Task {
//            try? await Task.sleep(nanoseconds: 7 * 1_000_000_000)
//            // Only show alert if data not loaded and ring not connected
//            if !ringManagerPro.dataLoaded && ringManagerPro.connectedPeripheral == nil {
//                await MainActor.run {
//                    showAlert = true
//                }
//            }
//        }
//    }
//
//    private func cancelTimeout() {
//        timeoutTask?.cancel()
//        timeoutTask = nil
//    }
    
    var body: some View {
        ZStack {
            VStack {
                switch ringManagerPro.selectedTab {
                case 0:
                    DashboardViewPro(ringManagerPro: ringManagerPro)
                case 1:
                    HeartRateScreenViewPro(ringManagerPro: ringManagerPro)
                case 2:
                    ActivityScreenViewPro(ringManagerPro: ringManagerPro)
                case 3:
                    SleepScreenViewPro(ringManagerPro: ringManagerPro)
                case 4:
                    ProfileScreenViewPro(ringManagerPro: ringManagerPro)
                default:
                    DashboardViewPro(ringManagerPro: ringManagerPro)
                }
            }
            VStack {
                Spacer()
                TabBarPro(ringManagerPro: ringManagerPro)
                    .padding(.bottom, -10)
            }
//                if !ringManagerPro.dataLoaded && (ringManagerPro.connectedPeripheral != nil) {
//                    VStack(spacing: 20) {
//                        ProgressView("Syncing data")
//                            .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
//                            .scaleEffect(1.2)
//                        Text("Please wait...")
//                    }
//                    .padding(20)
//                    .background(.ultraThinMaterial)
//                    .cornerRadius(16)
//                    .onAppear {
//                        startTimeout()
//                    }
//                    .onDisappear {
//                        cancelTimeout()
//                    }
//                    Color.black.opacity(0.1)
//                        .ignoresSafeArea()
//                        .allowsHitTesting(true)
//                }
        }
        .onAppear {
            ringManagerPro.selectedTheme = (colorScheme == .dark) ? .dark : .light
            NotificationPermissionManager.shared.requestPermissionIfNeeded { granted in
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("⚠️ Notification permission denied")
                }
            }
         }
//        .alert(
//            "Couldn't get data",
//            isPresented: $showAlert, // must be a Binding<Bool>
//            actions: {
//                Button("OK", role: .cancel) { }
//            },
//            message: {
//                Text("Please make sure the ring is binded and accessible to the phone")
//            }
//        )
    }
}
