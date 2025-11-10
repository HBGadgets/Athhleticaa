//
//  HRVCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 05/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct HRVCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var hrvManager: HRVManager
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }
    
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
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HRV")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(formattedToday)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                HRVChartView(data: hrvManager.hrvData ?? HRVModel(date: "0", values: [0], interval: 0))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        
    }
}
