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
                            ringManager.selectedTab = 0
                            dismiss()
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
