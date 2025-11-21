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
        
        VStack {
            Chart(categories) { cat in
                SectorMark(
                    angle: .value("Count", cat.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(cat.color)
                .cornerRadius(4)
                .opacity(selectedCategory?.id == cat.id ? 1.0 : 0.7)
//                .scaleEffect(selectedCategory?.id == cat.id ? 1.05 : 1.0)
//                .onTapGesture {
//                    withAnimation {
//                        selectedCategory = cat
//                    }
//                }
            }
            .chartLegend(.hidden)
//            .frame(height: 280)
            
            // Dynamic label on tap
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
        }
    }
}
