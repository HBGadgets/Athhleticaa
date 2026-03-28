//
//  ECGWaveFormViewCompleted.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 28/03/26.
//

import SwiftUI

struct ECGWaveformViewCompleted: View {
    var vpECGTestDataModel: VPECGTestDataModel
    
    @State private var signals: [CGFloat] = []
    private let pointsPerMm:  CGFloat = 3.78
    private let mmPerSecond:  CGFloat = 25   // paper speed
    private let mmPerMv:      CGFloat = 10   // amplitude gain
    private let samplingRate: CGFloat = 500  // Hz
    
    /// Horizontal distance (pts) between consecutive 500 Hz samples.
    private var pointsPerSample: CGFloat { mmPerSecond / samplingRate * pointsPerMm }
 
    /// Vertical distance (pts) per millivolt.
    private var pointsPerMv: CGFloat { mmPerMv * pointsPerMm }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: true) {
                ZStack {
                    ecgPath(for: signals, midY: geo.size.height / 2)
                        .stroke(Color.red, lineWidth: 1.5)
                }
                .frame(width: totalWidth, height: geo.size.height)
            }
            .onAppear {
                appendSignals(vpECGTestDataModel)
            }
        }
    }
    
    private var totalWidth: CGFloat {
        CGFloat(signals.count) * pointsPerSample
    }
 
    // ── Drawing ───────────────────────────────────────────────────────────
 
    /// Builds the ECG polyline using calibrated point-per-sample / point-per-mV spacing.
    private func ecgPath(for data: [CGFloat], midY: CGFloat) -> Path {
        Path { path in
            guard data.count > 1 else { return }
            for i in data.indices {
                let point = CGPoint(
                    x: CGFloat(i) * pointsPerSample,  // time axis  (25 mm/s @ 500 Hz)
                    y: midY - data[i] * pointsPerMv   // amplitude  (10 mm/mV)
                )
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }
 
    // ── Data ──────────────────────────────────────────────────────────────
 
    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        guard let filterSignals = ecgData.filterSignals,
              let ecgType       = ecgData.ecgType,
              let testType      = ecgData.type else { return }
 
        let gain = ecgData.getGainValue()
 
        let rawValues: [CGFloat] = filterSignals.compactMap {
            if let n = $0 as? NSNumber,
               let v = Double(exactly: n) { return CGFloat(v) }
            if let s = $0 as? NSString,
               let v = Double(s as String) { return CGFloat(v) }
            return nil
        }
 
        let mvValues: [CGFloat] = rawValues.map {
            VPECGTestDataModel.convertToMv(
                withValue: $0, ecgType: ecgType, testType: testType, gain: gain
            )
        }
 
        guard !mvValues.isEmpty else { return }
        // Keep only as many samples as fit on screen (one full sweep)
        signals = mvValues
    }
}
