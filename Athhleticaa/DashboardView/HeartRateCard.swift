//
//  HeartRateCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore

// MARK: - Heart Rate
struct HeartRateCard: View {
    var bpm: Int

    var body: some View {
        ZStack {
            // Base glossy background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .overlay(
                    // Inner edge shine (white glow around edges)
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white, lineWidth: 0.7)
                        .blur(radius: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 0.5
                                )
                                .blur(radius: 2)
                                .blendMode(.screen)
                        )
                )
                .overlay(
                    // Soft white reflection near top
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .blur(radius: 2)
                )

            // Content
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(bpm == 0 ? "..." : "\(bpm)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    HStack {
                        Text("Bpm")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}
