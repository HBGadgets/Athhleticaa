//
//  ActivityScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat = 10

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .animation(.easeOut(duration: 0.8), value: progress)
    }
}


struct ActivityScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Steps Today
                HStack {
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(ringManager.pedometerManager.stepsData?.totalSteps ?? 0)")
                                .font(.system(size: 36, weight: .bold))
    //                        Text("↑ 6%")
    //                            .font(.system(size: 16, weight: .medium))
    //                            .foregroundColor(.green)
                        }
                        Text("Steps Today")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    
                    Image(systemName: "shoeprints.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.green)
                    
                }
                .padding(.horizontal)

                // MARK: - Daily Activity Rings
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        ActivityRow(title: "Steps", value: Double(ringManager.pedometerManager.stepsData?.totalSteps ?? 0), goal: 8000, color: .orange)
                        ActivityRow(title: "Distance (Km)", value: Double(ringManager.pedometerManager.stepsData?.distance ?? 0) / 1000, goal: 6.0, color: .blue)
                        ActivityRow(title: "Calories (Kcal)", value: ringManager.pedometerManager.stepsData?.calories ?? 0, goal: 3000, color: .red)
                    }
                    Spacer()
                    ZStack {
                        ProgressRing(progress: (ringManager.pedometerManager.stepsData?.calories ?? 0) / 3000, color: .red)
                            .frame(width: 120, height: 120)
                        ProgressRing(progress: (Double(ringManager.pedometerManager.stepsData?.distance ?? 0) / 1000) / 6.0, color: .blue, lineWidth: 8)
                            .frame(width: 100, height: 100)
                        ProgressRing(progress: Double(ringManager.pedometerManager.stepsData?.totalSteps ?? 0) / 8000, color: .orange, lineWidth: 6)
                            .frame(width: 80, height: 80)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                
                PedometerChartsView(pedometerManager: ringManager.pedometerManager)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Activity Track").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ActivityRow: View {
    var title: String
    var value: Double
    var goal: Double
    var color: Color

    var body: some View {
        HStack {
            Text("•")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(String(format: "%.2f", value)) / \(String(format: "%.0f", goal))")
                    .font(.headline)
            }
        }
    }
}
