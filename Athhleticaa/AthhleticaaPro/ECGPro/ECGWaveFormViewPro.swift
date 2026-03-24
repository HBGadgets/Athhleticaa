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
                
                let stepX = width / CGFloat(maxPoints)
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
            guard let newData else { return }
            appendSignals(newData)
        }
        
    }
    
    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        guard let raw = ecgData.filterSignals as? [NSNumber],
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type else { return }
        
        let gain = ecgData.getGainValue()
        
        let newValues: [CGFloat] = raw.compactMap {
            let mv = VPECGTestDataModel.convertToMv(
                withValue: CGFloat($0.floatValue),
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
            return mv
        }
        
        signals.append(contentsOf: newValues)
        
        // keep buffer fixed (scrolling effect)
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
