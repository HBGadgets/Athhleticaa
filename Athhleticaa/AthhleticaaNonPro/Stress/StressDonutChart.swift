//
//  StressDonutChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/11/25.
//

import SwiftUI
import Charts

struct StressDonutChartView: View {
    let stress: StressModel
    @State private var selectedCategory: StressCategory?

    var body: some View {
        let categories = stress.categoryBreakdown
        
        HStack {
            Chart(categories) { cat in
                SectorMark(
                    angle: .value("Count", cat.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(cat.color)
                .cornerRadius(4)
            }
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
            VStack(alignment: HorizontalAlignment.leading) {
                HStack{
                    Text("•")
                        .foregroundStyle(.blue)
                    Text("Relax 0-29")
                        .font(.caption2)
                    Spacer()
                    Text("\(stress.relaxPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.teal)
                    Text("Normal 30-59")
                        .font(.caption2)
                    Spacer()
                    Text("\(stress.normalPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.yellow)
                    Text("Medium 60-79")
                        .font(.caption2)
                    Spacer()
                    Text("\(stress.mediumPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.red)
                    Text("High 80-100")
                        .font(.caption2)
                    Spacer()
                    Text("\(stress.highPercent) %")
                        .font(.caption2)
                }
            }
        }
    }
}
