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
            GeometryReader { geo in
                Image("StressCardImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped() // ✅ crops inside bounds
                    .overlay(
                        Color.black.opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .allowsHitTesting(false) // so image doesn’t block taps
            // Content
            VStack(spacing: 10) {
                // Top labels
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stress")
                            .font(.headline)
                            .fontWidth(.expanded)
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
                                .fontWidth(.expanded)
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Daily Range")
                                .font(.subheadline)
                            Text("\(rangeMin)-\(rangeMax)")
                                .font(.title3.bold())
                                .fontWidth(.expanded)
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
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
                .frame(width: 140, height: 140)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.green,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 140, height: 140)
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center text
            VStack(spacing: 6) {
                Text("\(stress)")
                    .font(.system(size: 28, weight: .bold))
                    .fontWidth(.expanded)
                
                Text(levelString)
            }
            .foregroundStyle(.white)
        }
    }
}
