//
//  Profile.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUI

import CoreBluetooth

struct DeviceInfoView: View {
    @State private var gestureControlEnabled = true
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager

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
                .background(colorScheme == .light ? Color.white : Color.black)
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

                        Toggle("", isOn: $gestureControlEnabled)
                            .labelsHidden()
                    }

                    Text("Gesture control will increase power consumption, please turn it off when not in use")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.leading, 36)
                        .lineLimit(2)
                }
                .padding()
                .background(colorScheme == .light ? Color.white : Color.black)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)

                // MARK: - Menu Buttons
                VStack(spacing: 12) {
                    DeviceMenuItem(icon: "dot.radiowaves.left.and.right", color: .mint, title: "Find Device")
                    DeviceMenuItem(icon: "brain.head.profile", color: .blue, title: "AI Analysis")
                    DeviceMenuItem(icon: "heart.fill", color: .pink, title: "Health Monitoring")
                    DeviceMenuItem(icon: "camera", color: .teal, title: "Take Picture")
                    DeviceMenuItem(icon: "gamecontroller", color: .orange, title: "Ring games")
                    DeviceMenuItem(icon: "tshirt", color: .purple, title: "App Theme")
                    DeviceMenuItem(icon: "thermometer.variable", color: .blue, title: "Temperature Unit")
                    DeviceMenuItem(icon: "battery.25percent", color: .red, title: "Low Battery Prompt")
                    DeviceMenuItem(icon: "heart.text.square", color: .red, title: "Apple Health")
                    DeviceMenuItem(icon: "square.and.arrow.up", color: .brown, title: "Firmware upgrade")
                    DeviceMenuItem(icon: "gear", color: .gray, title: "System Settings")
                }
            }
            .padding(.bottom, 100)
            .padding(.horizontal)
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

                Spacer()
            }
            .padding()
            .background(Color(colorScheme == .light ? .white : .black))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)
        }
        
    }
}
