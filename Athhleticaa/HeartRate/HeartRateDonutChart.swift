//
//  Untitled.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/12/25.
//

import SwiftUI
import Charts

struct HeartRateDonutChartView: View {
    let heartRate: HeartRateData
    @State private var selectedCategory: HeartRateCategory?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let categories = heartRate.categoryBreakdown
        HStack(spacing: 12) {
            Chart(categories) { cat in
                SectorMark(
                    angle: .value("Count", cat.count ?? 0),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(cat.color)
                .cornerRadius(4)
            }
            .frame(width: 100, height: 100)
            .chartLegend(.hidden)
            if let selected = selectedCategory {
                VStack(spacing: 4) {
                    Text(selected.name)
                        .font(.title2)
                        .bold()
                    Text("\(selected.count) readings")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
            Spacer()
            VStack(alignment: HorizontalAlignment.leading) {
                HStack{
                    infoSection(color: .red, title: "Limit")
                    Spacer()
                    Text("\(heartRate.limitSeconds) min")
                        .font(.caption2)
                }
                HStack{
                    infoSection(color: .orange, title: "Anaerobic endurance")
                    Spacer()
                    Text("\(heartRate.anaerobicSeconds) min")
                        .font(.caption2)
                }
                HStack{
                    infoSection(color: .yellow, title: "Aerobic endurance")
                    Spacer()
                    Text("\(heartRate.aerobicSeconds) min")
                        .font(.caption2)
                }
                HStack{
                    infoSection(color: .green, title: "Fat burning")
                    Spacer()
                    Text("\(heartRate.fatBurningSeconds) min")
                        .font(.caption2)
                }
                HStack{
                    infoSection(color: .blue, title: "Warm up")
                    Spacer()
                    Text("\(heartRate.warmUpSeconds) min")
                        .font(.caption2)
                }
                HStack {
                    Spacer()
                    NavigationLink(destination: HeartRateInfoScreen()) {
                        Text("Note ⓘ")
                            .fontWeight(.bold)
                    }
                }
                
            }
        }
//        .frame(height: 100)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
    
    private func infoSection(color: Color, title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.caption2)
            }
        }
    }
}
