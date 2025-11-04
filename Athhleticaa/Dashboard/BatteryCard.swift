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
            GlassShape(color: Color.red, corner: 20)
            VStack(alignment: .leading, spacing: 8) {
                // Top label (left-aligned)
                Text("Battery")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()

                // Centered circle + percentage
                ZStack {
                    Circle()
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 15)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: CGFloat(charge) / 100)
                        .stroke(
                            charge < 20 ? Color.red : Color.yellow,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
//                        .scaleEffect(x: -1, y: 1, anchor: .center)
                        .frame(width: 80, height: 80)
                    Text("\(charge)%")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}
