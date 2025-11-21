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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack (alignment: .leading) {
                    GeometryReader { geo in
                        Image("RingImage")
                            .resizable()
                            .rotationEffect(.degrees(125))
                            .scaledToFill()
                            .frame(width: 180, height: 180, alignment: .leading)
                            .clipped()
                            .opacity(0.3)
                            .offset(x: -geo.size.width * 0.15)
                    }
                    HStack {
                        Image("RingImage")
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(-75))
                            .frame(width: 120, height: 120)
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                            .cornerRadius(12)
                            .padding(.leading, 20)
                        
                        Spacer()

                        if let device = ringManager.connectedPeripheral {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(device.name ?? "Unknown")")
                                    .font(.title3)
                                    .bold()
                                
                                Text("• Connected")
                                    .foregroundStyle(.green)
                                
                                HStack {
                                    Text("Battery: \(ringManager.batteryLevel ?? 0)%")
                                    if (ringManager.isCharging) {
                                        Image(systemName: "bolt.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                                
                                Button("Unbind") {
                                    ringManager.disconnect()
                                }
                                .backgroundStyle(.blue)
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Device not connected")
                                    .font(.title3)
                                    .bold()

                                NavigationLink(destination: ScanningPage(ringManager: ringManager)) {
                                    Text("Scan for ring")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Spacer()
                        
                    }
                }
                .clipped()
//                .padding()
                .background(colorScheme == .light ? Color.white : Color(.systemGray6))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.3)

                // MARK: - Gesture Control Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.blue)

                        Text("Gesture Control")
                            .font(.headline)
                            .bold()

                        Spacer()

                        Toggle("", isOn: $ringManager.isGestureEnabled)
                            .labelsHidden()
                            .onChange(of: ringManager.isGestureEnabled) {
                                ringManager.switchToPhotoUI()
                            }
                    }

                    Text("Gesture control will increase power consumption, please turn it off when not in use")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.leading, 36)
                        .lineLimit(2)
                }
                .padding()
                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)

                // MARK: - Menu Buttons
                VStack(spacing: 12) {
                    DeviceMenuItem(icon: "dot.radiowaves.left.and.right", color: .mint, title: "Find Device")
                    .onTapGesture {
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
//                    DeviceMenuItem(icon: "brain.head.profile", color: .blue, title: "AI Analysis")
                    NavigationLink(destination: HealthMonitoringScreen(ringManager: ringManager)) {
                        DeviceMenuItem(icon: "heart.fill", color: .pink, title: "Health Monitoring")
                    }
                    NavigationLink(destination: CameraView(ringManager: ringManager)) {
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
                    NavigationLink(destination: SystemSettingScreen(ringManager: ringManager)) {
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
