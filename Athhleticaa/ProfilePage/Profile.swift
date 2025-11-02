//
//  Profile.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

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

struct ProfileView: View {
    @StateObject var ringManager = QCCentralManager()
    
    var body: some View {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("QRing Connector")
                            .font(.title)

                        if let device = ringManager.connectedPeripheral {
                            Text("Connected to: \(device.name ?? "Unknown")")

                            if let battery = ringManager.batteryLevel {
                                Text("Battery: \(battery)/8")
                            }

                            if let heartRate = ringManager.heartRate {
                                Text("❤️ Heart Rate: \(heartRate) bpm")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }

                            VStack {
                                Button("Read Battery") {
                                    ringManager.readBattery()
                                }
                                NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
                                    Text("Go to HRV Screen")
        //                            Button("Check HRV") {
        //                                ringManager.measureHRV()
        //                            }
                                }

                                NavigationLink(destination: HeartRateScreenView(ringManager: ringManager)) {
                                    Text("Go to Heart rate Screen")
                                }
                                Button("Read heart rate") {
                                    ringManager.measureHeartRate()
                                }
                                Button("Disconnect") {
                                    ringManager.disconnect()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 10)

                        } else {
                            Button("Scan Rings") {
                                ringManager.scan()
                            }
                            .buttonStyle(.borderedProminent)

                            if ringManager.peripherals.isEmpty {
                                ProgressView("Scanning...")
                                    .padding()
                            } else {
                                List(ringManager.peripherals, id: \.peripheral.identifier) { qcPer in
                                    Button(qcPer.peripheral.name ?? "Unknown") {
                                        ringManager.connect(to: qcPer.peripheral)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
    }
}
