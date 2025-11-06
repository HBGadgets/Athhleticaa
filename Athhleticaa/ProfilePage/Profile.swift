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
                // MARK: - Device Card
                HStack {
                    Image("RingImage") // Replace with actual asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(12)
                    
                    Spacer()

                    if let device = ringManager.connectedPeripheral {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(device.name ?? "Unknown")")
                                .font(.title3)
                                .bold()

                            Label("Connected", systemImage: "bolt.horizontal.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .labelStyle(.titleAndIcon)

                            Label("\(ringManager.batteryLevel ?? 0)%)", systemImage: "\(ringManager.isCharging ? "bolt.fill" : "")")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .labelStyle(.titleAndIcon)
                            
                            Button("Disconnect") {
                                ringManager.disconnect()
                            }
                        }
                        .padding(.leading, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Device not connected")
                                .font(.title3)
                                .bold()

                            NavigationLink(destination: ScanningPage(ringManager: ringManager)) {
                                Text("Scan for ring")
                            }
                        }
                        .padding(.leading, 8)
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)

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
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)

                // MARK: - Menu Buttons
                VStack(spacing: 12) {
                    DeviceMenuItem(icon: "dot.radiowaves.left.and.right", color: .mint, title: "Find Device")
                    DeviceMenuItem(icon: "brain.head.profile", color: .blue, title: "AI Analysis")
                    DeviceMenuItem(icon: "heart.fill", color: .green, title: "Health Monitoring")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
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
        .background(Color(.systemGray6))
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Subview for Menu Items
struct DeviceMenuItem: View {
    var icon: String
    var color: Color
    var title: String

    var body: some View {
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
                .foregroundColor(.black)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
//
//struct ProfileView: View {
////    @ObservedObject var ringManager = QCCentralManager
//    @ObservedObject var ringManager: QCCentralManager
//    
//    var body: some View {
//                NavigationStack {
//                    VStack(spacing: 20) {
//                        Text("QRing Connector")
//                            .font(.title)
//
//                        if let device = ringManager.connectedPeripheral {
//                            Text("Connected to: \(device.name ?? "Unknown")")
//
//                            if let battery = ringManager.batteryLevel {
//                                Text("Battery: \(battery)/8")
//                            }
//
//                            if let heartRate = ringManager.heartRate {
//                                Text("❤️ Heart Rate: \(heartRate) bpm")
//                                    .font(.headline)
//                                    .foregroundColor(.red)
//                            }
//
//                            VStack {
//                                Button("Read Battery") {
//                                    ringManager.readBattery()
//                                }
//                                NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
//                                    Text("Go to HRV Screen")
//        //                            Button("Check HRV") {
//        //                                ringManager.measureHRV()
//        //                            }
//                                }
//
//                                NavigationLink(destination: HeartRateScreenView(ringManager: ringManager)) {
//                                    Text("Go to Heart rate Screen")
//                                }
//                                Button("Read heart rate") {
//                                    ringManager.measureHeartRate()
//                                }
//                                Button("Disconnect") {
//                                    ringManager.disconnect()
//                                }
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .padding(.top, 10)
//
//                        } else {
//                            Button("Scan Rings") {
//                                ringManager.scan()
//                            }
//                            .buttonStyle(.borderedProminent)
//
//                            if ringManager.peripherals.isEmpty {
//                                ProgressView("Scanning...")
//                                    .padding()
//                            } else {
//                                List(ringManager.peripherals, id: \.peripheral.identifier) { qcPer in
//                                    Button(qcPer.peripheral.name ?? "Unknown") {
//                                        ringManager.connect(to: qcPer.peripheral)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//    }
//}
