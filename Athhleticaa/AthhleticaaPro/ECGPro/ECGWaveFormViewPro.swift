//
//  ECGWaveFormView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/03/26.
//

import SwiftUI

struct ECGWaveformView: View {
    @ObservedObject var ringManagerPro: RingManagerPro
 
    // ── ECG Standard Parameters ───────────────────────────────────────────
    /// Calibrate this to match your target device's physical screen density.
    /// See the file header for per-device reference values.
    private let pointsPerMm:  CGFloat = 3.78
    private let mmPerSecond:  CGFloat = 25   // paper speed
    private let mmPerMv:      CGFloat = 10   // amplitude gain
    private let samplingRate: CGFloat = 500  // Hz
 
    /// Horizontal distance (pts) between consecutive 500 Hz samples.
    private var pointsPerSample: CGFloat { mmPerSecond / samplingRate * pointsPerMm }
 
    /// Vertical distance (pts) per millivolt.
    private var pointsPerMv: CGFloat { mmPerMv * pointsPerMm }
 
    // ── State ─────────────────────────────────────────────────────────────
    @State private var signals:             [CGFloat]    = []
    @State private var previousSignals:     [CGFloat]    = []
    @State private var previousLineOpacity: Double       = 0
    @State private var drawProgress:        CGFloat      = 0
    @State private var samplesPerScreen:    Int          = 2000      // updated from geometry
    @State private var cycleDuration:       TimeInterval = 4.0       // updated from geometry
 
    private let animationTimer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()
    @State private var animationStartDate: Date?
    @State private var pendingData:        VPECGTestDataModel?
    @State private var lastCycleIndex:     Int = 0
 
    // ── Body ──────────────────────────────────────────────────────────────
 
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Previous sweep — fades out over half a cycle
                if previousSignals.count > 1 {
                    ecgPath(for: previousSignals, midY: geo.size.height / 2)
                        .stroke(Color.red, lineWidth: 1.5)
                        .opacity(previousLineOpacity)
                }
 
                // Current sweep — draws in from left
                if signals.count > 1 {
                    ecgPath(for: signals, midY: geo.size.height / 2)
                        .trim(from: 0, to: drawProgress)
                        .stroke(Color.red, lineWidth: 1.5)
                }
            }
            .onAppear {
                updateLayout(width: geo.size.width)
                animationStartDate = Date()
            }
            .onChange(of: geo.size.width) { _, newWidth in
                updateLayout(width: newWidth)
            }
        }
        .onReceive(animationTimer) { now in
            guard let start = animationStartDate else { return }
            let elapsed = now.timeIntervalSince(start)
 
            drawProgress = CGFloat(elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration)
 
            let currentCycle = Int(elapsed / cycleDuration)
            guard currentCycle > lastCycleIndex else { return }
            lastCycleIndex = currentCycle
 
            // Archive the completed sweep and fade it out
            if !signals.isEmpty {
                previousSignals     = signals
                previousLineOpacity = 1.0
                withAnimation(.easeOut(duration: cycleDuration * 0.5)) {
                    previousLineOpacity = 0
                }
            }
 
            // Apply buffered incoming data at cycle boundary
            if let data = pendingData {
                appendSignals(data)
                pendingData = nil
            }
        }
        .onChange(of: ringManagerPro.vpECGTestDataModel) { _, newData in
            pendingData = newData
        }
    }
 
    // ── Layout ────────────────────────────────────────────────────────────
 
    /// Recomputes how many 500 Hz samples fit across `width` points at
    /// 25 mm/s and derives the matching sweep cycle duration.
    private func updateLayout(width: CGFloat) {
        samplesPerScreen = max(1, Int(width / pointsPerSample))
        cycleDuration    = TimeInterval(samplesPerScreen) / TimeInterval(samplingRate)
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
        signals = Array(mvValues.suffix(samplesPerScreen))
    }
}
 
// MARK: - ECGGrid
 
/// Standard ECG paper grid.
/// Small squares = 1 mm (0.04 s · 0.1 mV), large squares = 5 mm (0.2 s · 0.5 mV).
///
/// `pointsPerMm` **must match** the value used in `ECGWaveformView`.
struct ECGGrid: View {
    private let pointsPerMm: CGFloat = 3.78  // ← keep in sync with ECGWaveformView
 
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                // 1 mm small squares
                drawGrid(ctx: ctx, size: size,
                         spacing:   pointsPerMm,
                         color:     .color(Color.gray.opacity(0.4)),
                         lineWidth: 0.5)
 
                // 5 mm large squares
                drawGrid(ctx: ctx, size: size,
                         spacing:   pointsPerMm * 5,
                         color:     .color(Color.gray.opacity(0.7)),
                         lineWidth: 0.5)
            }
        }
    }
 
    private func drawGrid(
        ctx: GraphicsContext, size: CGSize,
        spacing: CGFloat, color: GraphicsContext.Shading, lineWidth: CGFloat
    ) {
        var path = Path()
        var x: CGFloat = 0
        while x <= size.width {
            path.move(to: .init(x: x, y: 0))
            path.addLine(to: .init(x: x, y: size.height))
            x += spacing
        }
        var y: CGFloat = 0
        while y <= size.height {
            path.move(to: .init(x: 0, y: y))
            path.addLine(to: .init(x: size.width, y: y))
            y += spacing
        }
        ctx.stroke(path, with: color, lineWidth: lineWidth)
    }
}
