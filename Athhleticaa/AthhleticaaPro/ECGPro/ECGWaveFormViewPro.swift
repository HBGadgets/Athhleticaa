//
//  ECGWaveFormView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/03/26.
//

import SwiftUI

struct ECGWaveformView: View {
    
    @ObservedObject var ringManagerPro: RingManagerPro
    
    @State private var signals: [CGFloat] = []
    private let maxPoints = 1500   // ~3 sec at 500Hz
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard signals.count > 1 else { return }
                
                let width = geo.size.width
                let height = geo.size.height
                
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
            }
            .stroke(Color.red, lineWidth: 2)
        }
        .onChange(of: ringManagerPro.vpECGTestDataModel) { oldData, newData in
            
            print("got raw ecgModel")
            guard let newData else { return }
            print("got ecgModel")
            appendSignals(newData)
        }
        
    }
    
    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        print("append signals ran")

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

        signals = newValues

        if signals.count > maxPoints {
            signals.removeFirst(signals.count - maxPoints)
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
