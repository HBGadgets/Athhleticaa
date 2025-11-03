//
//  SleepCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct SleepCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var sleepManager: SleepManager
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Example: 01 Nov 2025
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
                        Text("Sleep")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                        Text(formattedToday)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.white)
                }

                HStack(alignment: .center) {
                    if let summary = sleepManager.summary {
                        TotalSleepRingView(totalMinutes: summary.totalMinutes)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 70, weight: .semibold))
                        Text("\(sleepManager.summary?.score ?? 0)")
                            .font(.headline)
                        Text("Sleep score")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color.white)
                }
                .padding(.horizontal, 40)
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        
    }
}


struct TotalSleepRingView: View {
    let totalMinutes: Int
    let targetMinutes: Int = 480 // 8 hours goal
    
    var progress: Double {
        min(Double(totalMinutes) / Double(targetMinutes), 1.0)
    }
    
    private func formattedDuration(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return "\(h)h \(m)m"
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 20)
                .frame(width: 120, height: 120)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 120, height: 120)
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center text
            VStack(spacing: 6) {
                Text(formattedDuration(totalMinutes))
                    .font(.system(size: 18, weight: .bold))
                
                Text("Total Sleep")
                    .font(.caption)
            }
            .foregroundStyle(.white)
        }
    }
}
