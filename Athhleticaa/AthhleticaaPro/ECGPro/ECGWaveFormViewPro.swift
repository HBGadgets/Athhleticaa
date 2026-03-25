//
//  ECGWaveFormView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/03/26.
//

import SwiftUI

struct WaveformShape: Shape {
    var signals: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard signals.count > 1 else { return path }

        let width = rect.width
        let height = rect.height

        let stepX = width / CGFloat(signals.count - 1)
        let midY = height / 2

        let verticalScale: CGFloat = 40 // tweak for amplitude

        for i in signals.indices {
            let x = CGFloat(i) * stepX
            let y = midY - (signals[i] * verticalScale)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

struct ECGWaveformView: View {
    
    @ObservedObject var ringManagerPro: RingManagerPro
    
    @State private var signals: [CGFloat] = []
    @State private var drawProgress: CGFloat = 0
    private let sampleRate: Double = 500
    private let maxPoints = 1500   // ~3 sec at 500Hz
    
    var body: some View {
        WaveformShape(signals: signals)
            .trim(from: 0, to: drawProgress)
            .stroke(Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .onChange(of: ringManagerPro.vpECGTestDataModel) { oldData, newData in
            
            print("got raw ecgModel")
            guard let newData else { return }
            print("got ecgModel")
            appendSignals(newData)
        }
        
    }
    
    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        print("append signals ran")
        let oldCount = signals.count

        guard let filterSignals = ecgData.filterSignals,
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type
        else {
            print("missing data")
            return
        }

        let gain = ecgData.getGainValue()
        print("ECG Type: \(ecgType), Test Type: \(testType), Gain: \(gain)")

        let rawValues: [CGFloat] = filterSignals.compactMap { element in
            if let num = element as? NSNumber {
                return CGFloat(num.floatValue)
            }
            if let str = element as? NSString, let value = Double(str as String) {
                return CGFloat(value)
            }
            print("Unhandled signal element type:", type(of: element))
            return nil
        }

        let newValues: [CGFloat] = rawValues.map { adcValue in
            let voltage = VPECGTestDataModel.convertToMv(
                withValue: adcValue,
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
            print("ADC: \(adcValue) -> Voltage: \(voltage) mV")
            return voltage
        }

        if !newValues.isEmpty {
            print("Signal range: \(newValues.min() ?? 0) to \(newValues.max() ?? 0) mV")
        }

        signals.append(contentsOf: newValues)

        if signals.count > maxPoints {
            signals.removeFirst(signals.count - maxPoints)
        }

        // Animate the waveform drawing from left to right
        let newCount = signals.count
        guard !newValues.isEmpty, newCount > 1 else { return }

        // How many points were effectively added after any trimming
        let added = max(0, newCount - oldCount)
        guard added > 0 else { return }

        if oldCount <= 1 {
            // First draw: animate the whole line
            withAnimation(nil) { drawProgress = 0 }
            let duration = Double(newCount) / sampleRate
            withAnimation(.linear(duration: duration)) { drawProgress = 1 }
        } else {
            // Incremental reveal based on the number of new samples
            let startProgress = max(0, 1 - CGFloat(added) / CGFloat(newCount))
            withAnimation(nil) { drawProgress = startProgress }
            let duration = Double(added) / sampleRate
            withAnimation(.linear(duration: duration)) { drawProgress = 1 }
        }
    }
}

struct ECGGrid: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 10
                
                for x in stride(from: 0, to: geo.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                
                for y in stride(from: 0, to: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        }
    }
}
