//
//  ECGTopLeftInfoViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/03/26.
//

import SwiftUI

struct ECGTopLeftInfoViewPro: View {
    var vPPttValueModel: VPPttValueModel?

    var body: some View {
        content
            .padding(20)
            .modifier(GlassCardModifier(cornerRadius: 16))
            .cornerRadius(16)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 12) {
                Text(vPPttValueModel.map { String($0.heart) } ?? "-")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .monospacedDigit()

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))

                        Text("bpm")
                            .font(.system(size: 20, weight: .medium))
                    }
                }
            }

            HStack {
                Text("QTc \(vPPttValueModel.map { String($0.qt) } ?? "-")")
                    .font(.system(size: 22, weight: .medium))

                Text("HRV \(vPPttValueModel.map { String($0.hrv) } ?? "-")")
                    .font(.system(size: 22, weight: .medium))
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
