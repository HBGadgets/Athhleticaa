//
//  ScanningPage.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 06/11/25.
//

import SwiftUI
import CoreBluetooth

struct ScanningPage: View {
    @ObservedObject var ringManager: QCCentralManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bluetoothPermission = BluetoothPermissionManager()

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
                            ringManager.callAllFunctions()
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
        .alert("Bluetooth Permission Needed",
               isPresented: $bluetoothPermission.permissionDenied) {

            Button("Cancel", role: .cancel) {
                dismiss()
            }

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

        } message: {
            Text("Please allow Bluetooth access in Settings so your ring can connect.")
        }
    }
}


class BluetoothPermissionManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var permissionDenied = false

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth OK")
            permissionDenied = false

        case .unauthorized:
            print("Bluetooth denied")
            permissionDenied = true     // 👈 Trigger SwiftUI alert

        case .poweredOff:
            print("Bluetooth off")

        default:
            break
        }
    }
}
