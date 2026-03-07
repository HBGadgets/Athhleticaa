//
//  BloodOxygenDonutChart.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/11/25.
//

import SwiftUI
import Charts

struct BloodOxygenDonutChart: View {
    @ObservedObject var manager: BloodOxygenManager
    @State private var selectedID: UUID?

    var body: some View {
        let categories = manager.donutCategoryBreakdown

        HStack {
            Chart(categories) { cat in
                SectorMark(
                    angle: .value("Count", cat.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(cat.color)
                .opacity(selectedID == nil || selectedID == cat.id ? 1.0 : 0.4)
                .accessibilityLabel(cat.name)
                .accessibilityValue("\(cat.count) readings")
                .cornerRadius(4)
            }
            .chartLegend(.hidden)

            // MARK: Center Label
            if let selected = categories.first(where: { $0.id == selectedID }) {
                VStack(spacing: 4) {
                    Text(selected.name)
                        .font(.title2).bold()
                    Text("\(selected.count) readings")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            VStack(alignment: HorizontalAlignment.leading) {
                HStack{
                    Text("•")
                        .foregroundStyle(.red)
                    Text("Low <95")
                        .font(.caption2)
                    Spacer()
                    Text("\(manager.lowPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.blue)
                    Text("Normal 95-97")
                        .font(.caption2)
                    Spacer()
                    Text("\(manager.normalPercent) %")
                        .font(.caption2)
                }
                HStack{
                    Text("•")
                        .foregroundStyle(.green)
                    Text("Excellent > 98")
                        .font(.caption2)
                    Spacer()
                    Text("\(manager.highPercent) %")
                        .font(.caption2)
                }
            }
        }
    }
}
