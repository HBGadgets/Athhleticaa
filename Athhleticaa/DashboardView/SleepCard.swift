//
//  SleepCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore
import Charts


// MARK: - Sleep
struct SleepCard: View {
    @Environment(\.colorScheme) var colorScheme
    var hours: Int
    var minutes: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "#b06510") : Color(hex: "#ff9214"))
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Time asleep")
                    .font(.headline)
                    .foregroundColor(Color.white)
                Text("\(hours)h \(minutes)m")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                Chart {
                    ForEach(0..<8, id: \.self) { i in
                        LineMark(
                            x: .value("Time", i),
                            y: .value("Depth", Int.random(in: 1...5))
                        )
                    }
                }
                .frame(height: 60)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        
    }
}
