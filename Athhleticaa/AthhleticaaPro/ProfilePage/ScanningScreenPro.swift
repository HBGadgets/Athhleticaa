//
//  ScanningPagePro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/03/26.
//

import SwiftUI

struct ScanningScreenPro: View {
    @StateObject var ringManager = RingManagerPro.shared
      
    var body: some View {
        List(ringManager.scannedDevices, id: \.deviceAddress) { device in
            Button {
                ringManager.connectDevice(device)
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
