//
//  ChargeCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore


// MARK: - Battery
struct BatteryCard: View {
    @Environment(\.colorScheme) var colorScheme
    var charge: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.1))
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
                .clipShape(RoundedRectangle(cornerRadius: 20))

            // Content
            VStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: CGFloat(charge) / 100)
                        .stroke(charge < 20 ? Color.red : Color.green, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                    Text("\(charge)%")
                        .font(.headline)
                }
                Text("Charge")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        
    }
}
