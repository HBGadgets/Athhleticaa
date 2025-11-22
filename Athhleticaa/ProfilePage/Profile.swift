//
//  Profile.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUI

import CoreBluetooth

struct DeviceInfoView: View {
    @State private var showThemeSheet = false
    @State private var showFindDeviceSheet = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
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
                RingConnectView(ringManager: ringManager)

                // MARK: - Gesture Control Card
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Image(systemName: "hand.tap.fill")
//                            .resizable()
//                            .frame(width: 28, height: 28)
//                            .foregroundColor(.blue)
//
//                        Text("Gesture Control")
//                            .font(.headline)
//                            .bold()
//
//                        Spacer()
//
//                        Toggle("", isOn: $ringManager.isGestureEnabled)
//                            .labelsHidden()
//                            .onChange(of: ringManager.isGestureEnabled) {
//                                ringManager.switchToPhotoUI()
//                            }
//                    }
//
//                    Text("Gesture control will increase power consumption, please turn it off when not in use")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                        .padding(.leading, 36)
//                        .lineLimit(2)
//                }
//                .padding()
//                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
//                .cornerRadius(16)
//                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)

                // MARK: - Menu Buttons
                VStack(spacing: 12) {
                    
//                    DeviceMenuItem(icon: "brain.head.profile", color: .blue, title: "AI Analysis")
//                    NavigationLink(destination: HealthMonitoringScreen(ringManager: ringManager)) {
//                        DeviceMenuItem(icon: "heart.fill", color: .pink, title: "Health Monitoring")
//                    }
                    Button {
                        if ringManager.connectedPeripheral != nil {
                            findDevice()
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(icon: "dot.radiowaves.left.and.right", color: .mint, title: "Find Device")
                    }
                    Button {
                        if ringManager.connectedPeripheral != nil {
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
                        if ringManager.connectedPeripheral != nil {
                            goToCamerView = true
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(icon: "camera", color: .teal, title: "Take Picture")
                    }
                    
//                    DeviceMenuItem(icon: "gamecontroller", color: .orange, title: "Ring games")
                    DeviceMenuItem(icon: "tshirt", color: .purple, title: "App Theme")
                        .onTapGesture {
                            showThemeSheet = true
                        }
//                    DeviceMenuItem(icon: "thermometer.variable", color: .blue, title: "Temperature Unit")
//                    DeviceMenuItem(icon: "battery.25percent", color: .red, title: "Low Battery Prompt")
                    DeviceMenuItem(icon: "heart.text.square", color: .red, title: "Apple Health")
                        .onTapGesture {
                            HealthKitManager.shared.requestAuthorization { success in
                                showAuthSuccessAlert = true
                            }
                        }
//                    DeviceMenuItem(icon: "square.and.arrow.up", color: .brown, title: "Firmware upgrade")
                    Button {
                        if ringManager.connectedPeripheral != nil {
                            goToSystemSettings = true
                        } else {
                            showNavigationError = true
                        }
                    } label: {
                        DeviceMenuItem(icon: "gear", color: .gray, title: "System Setting")
                    }
                }
            }
            .padding(.bottom, 150)
            .padding(.horizontal)
            .sheet(isPresented: $showThemeSheet) {
                ThemeBottomSheet(selectedTheme: $ringManager.selectedTheme)
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
            .navigationDestination(isPresented: $goToHealthScreen) {
                HealthMonitoringScreen(ringManager: ringManager)
            }
            .navigationDestination(isPresented: $goToCamerView) {
                CameraView(ringManager: ringManager)
            }
            .navigationDestination(isPresented: $goToSystemSettings) {
                SystemSettingScreen(ringManager: ringManager)
            }
            .navigationDestination(isPresented: $goToScanScreen) {
                ScanningPage(ringManager: ringManager)
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Subview for Menu Items
struct DeviceMenuItem: View {
    @Environment(\.colorScheme) var colorScheme
    var icon: String
    var color: Color
    var title: String

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(color)
                    .padding(8)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .light ? Color.black : Color.white)

                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)
        }
        
    }
}
