//
//  ScanningPage.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 06/11/25.
//

import SwiftUI

struct ScanningPage: View {
    @ObservedObject var ringManager: QCCentralManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if ringManager.peripherals.isEmpty {
                ProgressView("Scanning...")
                    .padding()
            } else {
                List(ringManager.peripherals, id: \.peripheral.identifier) { qcPer in
                    Button(qcPer.peripheral.name ?? "Unknown") {
                        ringManager.connect(to: qcPer.peripheral) {
                            ringManager.stopScan()
                            ringManager.selectedTab = 0
                            dismiss()
                            ringManager.heartRateManager.fetchTodayHeartRate() {
                                ringManager.pedometerManager.getPedometerData() {
                                    ringManager.stressManager.fetchStressData() {
                                        ringManager.sleepManager.getSleep(day: 0) {
                                            ringManager.readBattery() {
                                                ringManager.bloodOxygenManager.fetchBloodOxygenData() {
                                                    ringManager.hrvManager.fetchHRV() {
                                                        ringManager.dataLoaded = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Scan Rings")
        .onAppear {
            print("🔍 Starting scan...")
            ringManager.scan()
        }
    }
}
