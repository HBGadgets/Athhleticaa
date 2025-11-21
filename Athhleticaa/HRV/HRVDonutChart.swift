//
//  HRVDonutChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/11/25.
//

import SwiftUI
import Charts

struct HRVDonutChartView: View {
    let hrv: HRVModel
    @State private var selectedCategory: HRVCategory?

    var body: some View {
        let categories = hrv.categoryBreakdown
        
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
                        .foregroundStyle(.red)
                    Text("Low <30")
                        .font(.caption2)
                    Spacer()
                    Text("\(hrv.lowPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.yellow)
                    Text("Normal 30-60")
                        .font(.caption2)
                    Spacer()
                    Text("\(hrv.normalPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.green)
                    Text("Good 61-101")
                        .font(.caption2)
                    Spacer()
                    Text("\(hrv.highPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.blue)
                    Text("Excellent >101")
                        .font(.caption2)
                    Spacer()
                    Text("\(hrv.veryHighPercent) %")
                        .font(.caption2)
                }
            }
        }
    }
}
