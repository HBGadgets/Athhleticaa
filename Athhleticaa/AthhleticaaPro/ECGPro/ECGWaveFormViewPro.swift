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

    // Previous line fade
    @State private var previousSignals: [CGFloat] = []
    @State private var previousLineOpacity: Double = 0

    private let animationTimer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()
    @State private var animationStartDate: Date?

    @State private var pendingData: VPECGTestDataModel?
    @State private var lastCycleIndex: Int = 0
    let cycleDuration: TimeInterval = 4

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Previous line (fades out) ──────────────────────────────
                if previousSignals.count > 1 {
                    ecgPath(for: previousSignals, in: geo.size)
                        .trim(from: 0, to: 1)               // always fully drawn
                        .stroke(Color.red, lineWidth: 2)
                        .opacity(previousLineOpacity)
                }

                // ── Current line (draws in) ────────────────────────────────
                if signals.count > 1 {
                    ecgPath(for: signals, in: geo.size)
                        .trim(from: 0, to: drawProgress)
                        .stroke(Color.red, lineWidth: 2)
                }
            }
        }
        .onAppear {
            animationStartDate = Date()
        }
        .onReceive(animationTimer) { now in
            guard let start = animationStartDate else { return }
            let elapsed = now.timeIntervalSince(start)
            drawProgress = CGFloat(elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration)

            let currentCycle = Int(elapsed / cycleDuration)

            if currentCycle > lastCycleIndex {
                lastCycleIndex = currentCycle

                // Save current line as the "previous" and trigger fade-out
                if !signals.isEmpty {
                    previousSignals = signals
                    previousLineOpacity = 1.0

                    withAnimation(.easeOut(duration: cycleDuration * 0.5)) {
                        previousLineOpacity = 0
                    }
                }

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

    // ── Helpers ───────────────────────────────────────────────────────────────

    /// Builds the ECG Path for any signal array inside the given size.
    private func ecgPath(for data: [CGFloat], in size: CGSize) -> Path {
        Path { path in
            guard data.count > 1 else { return }

            let stepX = size.width / CGFloat(data.count - 1)
            let midY = size.height / 2
            let verticalScale: CGFloat = 40

            for i in data.indices {
                let x = CGFloat(i) * stepX
                let y = midY - (data[i] * verticalScale)
                i == 0 ? path.move(to: CGPoint(x: x, y: y))
                       : path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }

    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        guard let filterSignals = ecgData.filterSignals,
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type else { return }

        let gain = ecgData.getGainValue()

        let rawValues: [CGFloat] = filterSignals.compactMap { element in
            if let num = element as? NSNumber { return CGFloat(num.floatValue) }
            if let str = element as? NSString, let value = Double(str as String) { return CGFloat(value) }
            return nil
        }

        let newValues: [CGFloat] = rawValues.map {
            VPECGTestDataModel.convertToMv(withValue: $0, ecgType: ecgType, testType: testType, gain: gain)
        }

        guard !newValues.isEmpty else { return }
        print("newValues count ====>>>> \(newValues.count)")
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
