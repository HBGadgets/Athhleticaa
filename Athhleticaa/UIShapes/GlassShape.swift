//
//  GlassShape.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 03/11/25.
//

import SwiftUICore

struct GlassShape: View {
    @Environment(\.colorScheme) var colorScheme
    var color: Color
    var corner: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(colorScheme == .dark ? color.opacity(0.1) : color.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .strokeBorder(Color.white, lineWidth: 0.7)
                        .blur(radius: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: corner)
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
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: corner))
                    .blur(radius: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: corner))
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(corner)
    }
}
