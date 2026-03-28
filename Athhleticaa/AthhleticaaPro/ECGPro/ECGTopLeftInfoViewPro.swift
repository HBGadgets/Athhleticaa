//
//  ECGTopLeftInfoViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/03/26.
//

import SwiftUI

struct ECGTopLeftInfoViewPro: View {
    var bpm: Int32?
    var hrv: Int32?
    var qtc: Int32?

    var body: some View {
        content
            .padding(20)
            .modifier(GlassCardModifier(cornerRadius: 16))
            .cornerRadius(16)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 12) {
                Text(bpm.map(String.init) ?? "--")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .monospacedDigit()

                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))

                    Text("bpm")
                        .font(.system(size: 12, weight: .medium))
                }
            }

            HStack {
                Text("QTc \(qtc.map(String.init) ?? "---")")
                    .font(.system(size: 15, weight: .medium))

                Text("HRV \(hrv.map(String.init) ?? "--")")
                    .font(.system(size: 15, weight: .medium))
            }
        }
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: Double
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            content.background(.ultraThinMaterial)
        }
    }
}
