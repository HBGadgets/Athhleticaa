//
//  ECGtakingScreenViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 24/03/26.
//

import SwiftUI

struct ECGtakingScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var currentHeartRate: Int? = nil
    @State private var showCalendar = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    @State private var goToMeasurementView = false
    @State private var handRemoved = false
    @State private var buttonTitle = "Tap to start measurement"
    @State private var testCompleted = false
    @State private var showTestCompletedAlert = false
    @State private var goToECGTestReviewScreen = false
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }
    
    private func safeInt32(from value: Any?) -> Int32? {
        switch value {
        case let v as Int32: return v
        case let v as Int: return Int32(v)
        case let v as Double: return Int32(v)
        case let v as Float: return Int32(v)
        case let v as String: return Int32(v)
        case .none: return nil
        default: return nil
        }
    }
    
    var body: some View {
        ZStack {
            ECGGrid()

            // Waveform layer
            Group {
                if testCompleted {
                    let model = ringManagerPro.vpECGTestDataModel ?? VPECGTestDataModel()
                    ECGWaveformViewCompleted(vpECGTestDataModel: model)
                } else {
                    ECGWaveformView(ringManagerPro: ringManagerPro)
                }
            }

            // Top-left info
            Group {
                if testCompleted {
                    ECGTopLeftInfoViewPro(
                        bpm: safeInt32(from: ringManagerPro.vpECGTestDataModel?.aveHeart),
                        hrv: safeInt32(from: ringManagerPro.vpECGTestDataModel?.aveHrv),
                        qtc: safeInt32(from: ringManagerPro.vpECGTestDataModel?.aveQT)
                    )
                } else {
                    ECGTopLeftInfoViewPro(
                        bpm: ringManagerPro.vpttTestModel?.heart,
                        hrv: ringManagerPro.vpttTestModel?.hrv,
                        qtc: ringManagerPro.vpttTestModel?.qt
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(12)
            
            Text("25 mm/s, 10 mm/mV, 500Hz")
                .padding()
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            if handRemoved {
                VStack(spacing: 20) {
                    Text("Ensure your fingers are on electrode")
                }
                .padding(20)
                .cornerRadius(16)
                .modifier(GlassCardModifier(cornerRadius: 16))

                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
        .onChange(of: ringManagerPro.handRemovedFromElectrode) { _, newValue in
            handRemoved = newValue
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                if ringManagerPro.connectedPeripheral != nil {
                    ringManagerPro.ecgManagerPro.startECGTest(ringManagerPro: ringManagerPro)
                } else {
                    showNavigationError = true
                }
            }) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))

                    GeometryReader { geo in
                        let progress = CGFloat(ringManagerPro.ecgTestProgress ?? 0) / 100.0

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.5))
                            .frame(width: geo.size.width * progress)
                            .animation(.easeInOut(duration: 0.2), value: progress)
                    }

                    Text(buttonTitle)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .frame(height: 50)
            }
            .disabled(ringManagerPro.ecgTestProgress != nil)
            .padding()
            
        }
        .onAppear() {
            testCompleted = ringManagerPro.ecgTestCompleted
        }
        .onChange(of: ringManagerPro.ecgTestProgress) { _, newValue in
            if let value = newValue {
                buttonTitle = "Measuring \(value)%"
                if value >= 100 {
                    testCompleted = true
                    showTestCompletedAlert = true
                }
            }
        }
        .onChange(of: ringManagerPro.ecgTestCompleted) { _, newValue in
            testCompleted = newValue
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToScanScreen) {
            ScanningScreenPro()
        }
        .navigationDestination(isPresented: $goToECGTestReviewScreen) {
            ECGReviewScreenPro(vpECGTestDataModel: ringManagerPro.vpECGTestDataModel ?? VPECGTestDataModel())
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
        .alert("ECG Test Completed", isPresented: $showTestCompletedAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("Review") {
                goToECGTestReviewScreen = true
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("ECG test completed, you can review results")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ECG").font(.headline)
            }
            
            if (testCompleted) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        goToECGTestReviewScreen = true
                    }) {
                        Text("Review")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    ringManagerPro.ecgManagerPro.stopECGTest()
                    ringManagerPro.ecgTestProgress = nil
                    ringManagerPro.vpttTestModel = nil
                    ringManagerPro.vpECGTestDataModel = nil
                    ringManagerPro.ecgTestCompleted = false
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
    }
}

