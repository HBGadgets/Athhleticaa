//
//  ECGWaveFormView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/03/26.
//

import SwiftUI

struct ECGWaveformView: View {
    let ecgData: VPECGTestDataModel
    @State private var convertedSignals: [CGFloat] = []
    @State private var refreshTimer: Timer?
      
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !convertedSignals.isEmpty else { return }
                  
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(convertedSignals.count - 1)
                  
                let minValue = convertedSignals.min() ?? 0
                let maxValue = convertedSignals.max() ?? 0
                let range = maxValue - minValue
                  
                for (index, value) in convertedSignals.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                    let y = height * (1 - normalizedValue)
                      
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.red, lineWidth: 2)
        }
        .onAppear {
            convertSignals()
            startRefreshTimer()
        }
        .onDisappear {
            stopRefreshTimer()
        }
    }
      
    private func startRefreshTimer() {
        // Refresh every 100ms as per SDK documentation
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            convertSignals()
        }
    }
      
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
      
    private func convertSignals() {
        guard let signals = ecgData.filterSignals as? [NSNumber],
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type else { return }
          
        let gain = ecgData.getGainValue()
          
        convertedSignals = signals.compactMap { signal in
            let adcValue = CGFloat(signal.floatValue)
            let voltage = VPECGTestDataModel.convertToMv(
                withValue: adcValue,
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
            return voltage > 0 ? voltage : 0
        }
    }
}
