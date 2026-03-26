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
    private let maxPoints = 1500
    @State private var drawProgress: CGFloat = 0

    // Drive progress independently from a continuous timer
    private let animationTimer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()
    @State private var animationStartDate: Date?
    
    @State private var pendingData: VPECGTestDataModel?
    @State private var lastCycleIndex: Int = 0
    let cycleDuration: TimeInterval = 4

    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard signals.count > 1 else { return }

                let width = geo.size.width
                let height = geo.size.height
                let stepX = width / CGFloat(signals.count - 1)
                let midY = height / 2
                let verticalScale: CGFloat = 40

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
            .trim(from: 0, to: drawProgress)
            .stroke(Color.red, lineWidth: 2)
        }
        .onAppear {
            animationStartDate = Date()
        }
        // Tick at ~60 fps and advance progress on a 4-second loop
        .onReceive(animationTimer) { now in
            guard let start = animationStartDate else { return }
            let elapsed = now.timeIntervalSince(start)
            drawProgress = CGFloat(elapsed.truncatingRemainder(dividingBy: 4) / 4)
            
            // Detect cycle index (integer increments every 4 sec)
            let currentCycle = Int(elapsed / cycleDuration)

            // When a new cycle starts → animation finished
            if currentCycle > lastCycleIndex {
                lastCycleIndex = currentCycle

                if let data = pendingData {
                    appendSignals(data)
                    pendingData = nil
                }
            }
        }
        .onChange(of: ringManagerPro.vpECGTestDataModel) { _, newData in
            pendingData = newData
        }
    }

    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        guard let filterSignals = ecgData.filterSignals,
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type else {
            return
        }

        let gain = ecgData.getGainValue()

        let rawValues: [CGFloat] = filterSignals.compactMap { element in
            if let num = element as? NSNumber {
                return CGFloat(num.floatValue)
            }
            if let str = element as? NSString, let value = Double(str as String) {
                return CGFloat(value)
            }
            return nil
        }

        let newValues: [CGFloat] = rawValues.map { adcValue in
            VPECGTestDataModel.convertToMv(
                withValue: adcValue,
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
        }

        guard !newValues.isEmpty else { return }

        // Only update the data — never touch drawProgress or start a new animation
        
        print("newValues count ====>>>> \(newValues.count)")
        
//        signals = newValues
//        if signals.count > maxPoints {
//            signals.removeFirst(signals.count - maxPoints)
//        }
        
        signals = newValues.suffix(1500)
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
