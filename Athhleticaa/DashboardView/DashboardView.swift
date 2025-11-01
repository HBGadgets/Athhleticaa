//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI

import SwiftUI
import Charts

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManager = QCCentralManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if ringManager.dataLoaded == true {
                        ScrollView {
                            VStack(spacing: 16) {
                                

                                // MARK: - Steps
                                StepsCard(
                                    calories: ringManager.pedometerManager.stepsData?.calories ?? 0,
                                    steps: ringManager.pedometerManager.stepsData?.totalSteps ?? 0,
                                    distance: Double(ringManager.pedometerManager.stepsData?.distance ?? 0) / 1000
                                )

                                // MARK: - Battery and Sleep
//                                HStack(spacing: 16) {
//                                    BatteryCard(charge: ringManager.batteryLevel ?? 0)
//                                    SleepCard(hours: 6, minutes: 38)
//                                }
                                
                                
                                // MARK: - Heart Rate
                                HStack {
                                    NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
                                        HeartRateCard(bpm: ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)
                                    }
                                    BatteryCard(charge: ringManager.batteryLevel ?? 0)
                                }
                                
                                SleepCard(hours: 6, minutes: 38)

                                // MARK: - Achievements
                                StressCard(
                                    lastStress: Double(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0),
                                    averageStress: ringManager.stressManager.averageStress,
                                    rangeMin: ringManager.stressManager.rangeMin,
                                    rangeMax: ringManager.stressManager.rangeMax
                                )
                            }
                            .padding()
                            .padding(.bottom, 100)
                        }
                    } else {
                        VStack(spacing: 20) {
                            ProgressView("Connecting to your device…")
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                            Text("Please wait while we connect to your ring.")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray6))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        colorScheme == .dark ?
                        Image(.athhleticaaLogoDarkMode)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                        :
                        Image(.athhleticaaLogoLightMode)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                }.navigationBarTitleDisplayMode(.inline)
                
                VStack {
                    Spacer()
                    TabBar()
                        .padding(.bottom, -10)
                }
            }
            
        }
    }
    
}

struct TabBar: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<4) { index in
                tabButton(for: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }

    @ViewBuilder
    func tabButton(for index: Int) -> some View {
        let icons = ["house.fill", "moon.fill", "heart.fill", "person.crop.circle"]
        let isSelected = selectedTab == index

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = index
            }
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                colorScheme == .dark ?
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                :
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black)
            }
        }
    }
}


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
                    Text("bpm")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}


struct StepsCard: View {
    var calories: Double
    var steps: Int
    var distance: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
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
            
            HStack() {
                VStack {
                    Image(systemName: "flame")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text(String(format: "%.2f", calories).prefix(2))
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Kcal")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text("\(steps)")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Steps")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text(String(format: "%.2f", distance))
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Km")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity) // ✅ full width
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .cornerRadius(16)
        }
        
    }
}


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

// MARK: - Sleep
struct SleepCard: View {
    @Environment(\.colorScheme) var colorScheme
    var hours: Int
    var minutes: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time asleep")
                .font(.headline)
            Text("\(hours)h \(minutes)m")
                .font(.title)
                .fontWeight(.bold)
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
        .background(colorScheme == .dark ? Color.gray.opacity(0.1) : Color.white)
        .cornerRadius(16)
    }
}

struct StressCard: View {
    @Environment(\.colorScheme) var colorScheme
    var lastStress: Double
    var averageStress: Double
    var rangeMin: Int
    var rangeMax: Int
    var date: String = "01 Nov 2025"
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.1))
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
            VStack(spacing: 10) {
                // Top labels
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stress")
                            .font(.headline)
                        Text(date)
                            .font(.subheadline)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                
                Spacer()
                
                // Arc + Center value
                ZStack {
                    ArcShape(progress: 1.0)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 160, height: 160)
                    
                    ArcShape(progress: lastStress / 100)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, style: StrokeStyle(lineWidth: 12, lineCap: .round))
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
        }
        
    }
    
    private func stressLevelText(for value: Double) -> String {
        switch value {
        case ..<30: return "Low"
        case 30..<70: return "Normal"
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
