//
//  StressCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore


struct StressCard: View {
    @Environment(\.colorScheme) var colorScheme
//    var lastStress: Double
    var averageStress: Double
    var rangeMin: Int
    var rangeMax: Int
    @ObservedObject var ringManager: QCCentralManager
    
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
                
//                Spacer()
                
                HStack {
                    Spacer()
                    
                    StressRingView(stress: ringManager.dashboardStressData.first?.lastNonZeroStress ?? 0)
                    
                    Spacer()
                    
                    VStack {
                        VStack(spacing: 4) {
                            Text("Daily Average")
                                .font(.subheadline)
                            Text("\(Int(averageStress))")
                                .font(.title3.bold())
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Daily Range")
                                .font(.subheadline)
                            Text("\(rangeMin)-\(rangeMax)")
                                .font(.title3.bold())
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
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

struct StressRingView: View {
    let stress: Int
    
    var progress: Double {
        min(Double(stress) / 100.0, 1.0)
    }
    
    private var levelString: String {
        switch stress {
        case 0...29: return "Low"
        case 30...59: return "Normal"
        default: return "High"
        }
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 20)
                .frame(width: 150, height: 150)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 150, height: 150)
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center text
            VStack(spacing: 6) {
                Text("\(stress)")
                    .font(.system(size: 28, weight: .bold))
                
                Text(levelString)
                    .font(.system(size: 28, weight: .bold))
            }
            .foregroundStyle(.white)
        }
    }
}
