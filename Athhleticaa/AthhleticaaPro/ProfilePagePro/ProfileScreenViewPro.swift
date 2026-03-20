//
//  Profile.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUI

import CoreBluetooth

struct ProfileScreenViewPro: View {
    @State private var showThemeSheet = false
    @State private var showFindDeviceSheet = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var showAuthSuccessAlert = false
    @State private var goToHealthScreen = false
    @State private var showNavigationError = false
    @State private var goToCamerView = false
    @State private var goToSystemSettings = false
    @State private var goToScanScreen = false
    
    func findDevice () {
        showFindDeviceSheet = true
        for i in 0..<4 { // 3 times
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                QCSDKCmdCreator.alertBindingSuccess({
                    print("✅ [\(i + 1)] Set the binding vibration successfully")
                }, fail: {
                    print("❌ [\(i + 1)] Failed to set binding vibration")
                })
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RingConnectViewPro(ringManagerPro: ringManagerPro)

                // MARK: - Menu Buttons
                VStack(spacing: 12) {
                    Button {
                        if ringManagerPro.connectedPeripheral != nil {
                            findDevice()
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(icon: "dot.radiowaves.left.and.right", color: .mint, title: "Find Device")
                    }
                    Button {
                        if ringManagerPro.connectedPeripheral != nil {
                            goToHealthScreen = true
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(
                            icon: "heart.fill",
                            color: .pink,
                            title: "Health Monitoring"
                        )
                    }
                    Button {
                        if ringManagerPro.connectedPeripheral != nil {
                            goToCamerView = true
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(icon: "camera", color: .teal, title: "Take Picture")
                    }
                    
//                    DeviceMenuItem(icon: "tshirt", color: .purple, title: "App Theme")
//                        .onTapGesture {
//                            showThemeSheet = true
//                        }
//                    DeviceMenuItemWithToggle(
//                        icon: "battery.25percent",
//                        color: .orange,
//                        title: "Low battery prompt",
//                        ringManager: ringManager,
//                        isEnabled: $ringManager.lowBatteryAlert
//                    )
////                    DeviceMenuItem(icon: "thermometer.variable", color: .blue, title: "Temperature Unit")
////                    DeviceMenuItem(icon: "battery.25percent", color: .red, title: "Low Battery Prompt")
//                    DeviceMenuItem(icon: "heart.text.square", color: .red, title: "Apple Health")
//                        .onTapGesture {
//                            HealthKitManager.shared.requestAuthorization { success in
//                                showAuthSuccessAlert = true
//                            }
//                        }
////                    DeviceMenuItem(icon: "square.and.arrow.up", color: .brown, title: "Firmware upgrade")
//                    Button {
//                        if ringManager.connectedPeripheral != nil {
//                            goToSystemSettings = true
//                        } else {
//                            showNavigationError = true
//                        }
//                    } label: {
//                        DeviceMenuItem(icon: "gear", color: .gray, title: "System Setting")
//                    }
                }
            }
            .padding(.bottom, 150)
            .padding(.horizontal)
            .sheet(isPresented: $showThemeSheet) {
                ThemeBottomSheet(selectedTheme: $ringManagerPro.selectedTheme)
            }
            .sheet(isPresented: $showFindDeviceSheet) {
                Text("Ring is glowing green")
                    .font(.headline)
                    .presentationDetents([.fraction(0.3)])
            }
            .alert("Confirmation", isPresented: $showAuthSuccessAlert) {
            } message: {
                Text("Ring data will be synced to Apple Health")
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
            
            // MARK: Navigations
//            .navigationDestination(isPresented: $goToHealthScreen) {
//                HealthMonitoringScreen(ringManager: ringManager)
//            }
//            .navigationDestination(isPresented: $goToCamerView) {
//                CameraView(ringManager: ringManager)
//            }
//            .navigationDestination(isPresented: $goToSystemSettings) {
//                SystemSettingScreen(ringManager: ringManager)
//            }
//            .navigationDestination(isPresented: $goToScanScreen) {
//                ScanningPage(ringManager: ringManager)
//            }
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}
