//
//  ECGWaveFormView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/03/26.
//

import SwiftUI
import SpriteKit

struct ECGWaveformView: View {
    
    @ObservedObject var ringManagerPro: RingManagerPro
    
    @State private var signals: [CGFloat] = []
    private let maxPoints = 1500   // ~3 sec at 500Hz
    
    private func getOptimalScale() -> CGFloat {
        guard !signals.isEmpty else { return 300 }
          
        let maxValue = signals.max() ?? 0
        let minValue = signals.min() ?? 0
        let signalRange = maxValue - minValue
          
        // Target 60% of view height for signal display
        let targetHeight: CGFloat = 0.6
        let viewHeight: CGFloat = 200 // Your view height
          
        return signalRange > 0 ? (viewHeight * targetHeight) / signalRange : 300
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ECGGrid()
                
                ECGSpriteView(manager: ringManagerPro)
            }
        }
        .onChange(of: ringManagerPro.vpECGTestDataModel?.hashValue) { _, _ in
            guard let ecgData = ringManagerPro.vpECGTestDataModel else { return }
            appendSignals(ecgData)
        }
    }
    
    private func appendSignals(_ ecgData: VPECGTestDataModel) {
        guard let raw = ecgData.filterSignals as? [NSNumber],
              let ecgType = ecgData.ecgType,
              let testType = ecgData.type else { return }
          
        let gain = ecgData.getGainValue()
        print("ECG Type: \(ecgType), Test Type: \(testType), Gain: \(gain)")
          
        let newValues: [CGFloat] = raw.compactMap {
            let adcValue = CGFloat($0.floatValue)
            let voltage = VPECGTestDataModel.convertToMv(
                withValue: adcValue,
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
            print("ADC: \(adcValue) -> Voltage: \(voltage) mV")
            return voltage
        }
          
        // Print signal range
        if !newValues.isEmpty {
            let minVal = newValues.min() ?? 0
            let maxVal = newValues.max() ?? 0
            print("Signal range: \(minVal) to \(maxVal) mV")
        }
          
        signals.append(contentsOf: newValues)
          
        if signals.count > maxPoints {
            signals.removeFirst(signals.count - maxPoints)
        }
    }
}

struct ECGGrid: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let smallSpacing: CGFloat = 5   // 1mm squares
                let largeSpacing: CGFloat = 25  // 5mm squares
                  
                // Small grid lines (lighter)
                for x in stride(from: 0, to: geo.size.width, by: smallSpacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                  
                for y in stride(from: 0, to: geo.size.height, by: smallSpacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
                  
                // Large grid lines (darker)
                for x in stride(from: 0, to: geo.size.width, by: largeSpacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                  
                for y in stride(from: 0, to: geo.size.height, by: largeSpacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        }
    }
}

struct ECGSpriteView: UIViewRepresentable {
    
    @ObservedObject var manager: RingManagerPro
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = ECGScene(size: CGSize(width: 300, height: 200))
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        context.coordinator.scene = scene
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        guard let data = manager.vpECGTestDataModel else { return }
        context.coordinator.scene?.append(data: data)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: ECGScene?
    }
}

class ECGScene: SKScene {
    
    private let waveformNode = SKShapeNode()
    
    private var signals: [CGFloat] = []
    private let maxPoints = 600
    
    override func didMove(to view: SKView) {
        
        waveformNode.strokeColor = .red
        waveformNode.lineWidth = 2
        addChild(waveformNode)
    }
    
    func append(data: VPECGTestDataModel) {
        guard let raw = data.filterSignals as? [NSNumber],
              let ecgType = data.ecgType,
              let testType = data.type else { return }
        
        let gain = data.getGainValue()
        
        let newValues: [CGFloat] = raw.compactMap {
            let adc = CGFloat($0.floatValue)
            return VPECGTestDataModel.convertToMv(
                withValue: adc,
                ecgType: ecgType,
                testType: testType,
                gain: gain
            )
        }
        
        signals.append(contentsOf: newValues)
        
        if signals.count > maxPoints {
            signals.removeFirst(signals.count - maxPoints)
        }
        
        redraw()
    }
    
    private func redraw() {
        guard signals.count > 1 else { return }
        
        let path = CGMutablePath()
        
        let width = size.width
        let height = size.height
        
        let stepX = width / CGFloat(max(signals.count - 1, 1))
        let midY = height / 2
        
        let scale = getScale(height: height)
        
        for (i, val) in signals.enumerated() {
            let x = CGFloat(i) * stepX
            let y = midY - val * scale
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        waveformNode.path = path
    }
    
    private func getScale(height: CGFloat) -> CGFloat {
        guard let max = signals.max(),
              let min = signals.min() else { return 100 }
        
        let range = max - min
        return range > 0 ? (height * 0.6) / range : 100
    }
}
