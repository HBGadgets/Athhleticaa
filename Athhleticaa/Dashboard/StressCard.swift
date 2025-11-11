//
//  StressCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore


struct StressCard: View {
    @Environment(\.colorScheme) var colorScheme
    var lastStress: Double
    var averageStress: Double
    var rangeMin: Int
    var rangeMax: Int
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Example: 01 Nov 2025
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color(hex: "#5ddffc"))
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
            VStack(spacing: 10) {
                // Top labels
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stress")
                            .font(.headline)
                        Text(formattedToday)
                            .font(.subheadline)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                
                Spacer()
                
                // Arc + Center value
                ZStack {
                    ArcShape(progress: 1.0)
                        .stroke(
                            Color.gray, style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                    
                    ArcShape(progress: lastStress / 100)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 160, height: 160)
                    
                    VStack(spacing: 6) {
                        Text("\(Int(lastStress))")
                            .font(.system(size: 48, weight: .bold))
                        Text(stressLevelText(for: averageStress))
                                                    .font(.headline)
                    }
                }
                
                Spacer()
                
                // Bottom details
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("Daily Average")
                            .font(.subheadline)
                        Text("\(Int(averageStress))")
                            .font(.title3.bold())
                        Text(stressLevelText(for: averageStress))
                            .font(.footnote)
                    }
                    VStack(spacing: 4) {
                        Text("Daily Range")
                            .font(.subheadline)
                        Text("\(rangeMin)-\(rangeMax)")
                            .font(.title3.bold())
                        Text(stressLevelText(for: averageStress))
                            .font(.footnote)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
//            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .foregroundColor(.white)
        }
        
    }
    
    private func stressLevelText(for value: Double) -> String {
        switch value {
        case 0...29: return "Low"
        case 30...59: return "Normal"
        default: return "High"
        }
    }
}

// MARK: - Arc Shape
struct ArcShape: Shape {
    var progress: Double // between 0.0 and 1.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startAngle = Angle(degrees: 135)
        let endAngle = Angle(degrees: 45)
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path.trimmedPath(from: 0, to: progress)
    }
}
