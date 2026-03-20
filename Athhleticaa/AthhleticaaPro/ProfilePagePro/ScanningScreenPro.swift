//
//  ScanningPagePro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/03/26.
//

import SwiftUI

struct ScanningScreenPro: View {
    @StateObject var ringManager = RingManagerPro.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss
      
    var body: some View {
        ZStack {
            List(ringManager.scannedDevices, id: \.deviceAddress) { device in
                Button {
                    showAlert = true
                    ringManager.connectDevice(device) { connectState in
                        switch connectState {

                        case .BlePoweredOff:
                            print("Bluetooth Off")

                        case .BleConnecting:
                            print("Connecting...")

                        case .BleConnectSuccess:
                            print("Connected")

                        case .BleConnectFailed:
                            print("Connect Failed")

                        case .BleVerifyPasswordSuccess:
                            print("Password Verified")
                            ringManager.selectedTab = 0
                            dismiss()
                            ringManager.callAllFunctions()

                        case .BleVerifyPasswordFailure:
                            print("Password Failed")

                        case .BleConnectTimeout:
                            print("Connection Timeout")
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(device.deviceName)  // SDK provides the name
                                .font(.headline)
                              
                            Text(device.deviceAddress)  // Use deviceAddress instead of UUID
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                          
                        Spacer()
                          
                        Text("RSSI \(device.rssi.intValue)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            if (showAlert == true) {
                VStack(spacing: 20) {
                    ProgressView("Connecting...")
                        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                        .scaleEffect(1.2)
                    Text("Please wait...")
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
        
        .navigationTitle("Scan Devices")
        .onAppear {
            ringManager.startScanning()
        }
        .onDisappear {
            // Stop scanning when leaving the view
            VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()
        }
    }
}
