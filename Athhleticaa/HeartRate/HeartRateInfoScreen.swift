//
//  HeartRateInfoScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/12/25.
//

import SwiftUI

struct HeartRateInfoScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
//                Text("Heart Rate Zones")
//                    .font(.system(size: 28, weight: .semibold))
//                    .padding(.horizontal)
//                
//                // MARK: - Colored Table
//                HStack(spacing: 0) {
//                    VStack(alignment: .leading, spacing: 1) {
//                        labelRow("High Intensity")
//                        labelRow("Anaerobic Training")
//                        labelRow("Aerobic Training")
//                        labelRow("Fat Burn")
//                        labelRow("Warm Up")
//                    }
//                    
//                    Spacer()
//                    
//                    VStack(spacing: 0) {
//                        valueRow("171", .red)
//                        valueRow("152", .orange)
//                        valueRow("133", .yellow)
//                        valueRow("114", .green)
//                        valueRow("95", .blue)
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//                .padding(.horizontal)
//                
//                // MARK: - Fitness Explanation
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("About Heart Rate Zones")
//                        .font(.system(size: 22, weight: .semibold))
//                    
//                    Text("Heart rate zones are commonly used in fitness to help structure workouts. Different intensity levels can support goals such as improving endurance, building stamina, or warming up safely. Values may vary between individuals.")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                    
//                    Divider().padding(.top, 8)
//                }
//                .padding(.horizontal)
                
                // MARK: - Zone Descriptions
                VStack(alignment: .leading, spacing: 30) {
//                    infoSection(
//                        color: .blue,
//                        title: "Warm-up Zone",
//                        text: "Light-intensity effort often used to prepare the body before more intensive activity."
//                    )
//                    
//                    infoSection(
//                        color: .green,
//                        title: "Fat Burn Zone",
//                        text: "Moderate-intensity training that supports general fitness and longer-duration workouts."
//                    )
//                    
//                    infoSection(
//                        color: .yellow,
//                        title: "Aerobic Training Zone",
//                        text: "Steady, continuous activity that helps build cardio endurance and overall stamina."
//                    )
//                    
//                    infoSection(
//                        color: .orange,
//                        title: "Anaerobic Training Zone",
//                        text: "Higher-intensity efforts used to improve performance, speed, or power for short periods."
//                    )
//                    
//                    infoSection(
//                        color: .red,
//                        title: "High Intensity Zone",
//                        text: "Very intense effort typically used for short bursts during advanced training sessions."
//                    )
                    
                    Text("This software and the associated smart ring device are not medical devices; the data and information provided are for reference only and must not be used as basis for clinical diagnosis or treatment. Users should consult a physician before making any medical decisions.")
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Heart Rate")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func labelRow(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .frame(height: 44, alignment: .center)
    }
    
    private func valueRow(_ text: String, _ color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.85))
            .frame(width: 65, height: 44)
            .overlay(
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
            )
    }
    
    private func infoSection(color: Color, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            Text(text)
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}
