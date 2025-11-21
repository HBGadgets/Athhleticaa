//
//  SleepChartNew.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 20/11/25.
//

import SwiftUI
import Charts

import SwiftUI
import Charts

struct SleepChartViewNew: View {
    @ObservedObject var sleepManager: SleepManagerNew
    
    var body: some View {
        let data = self.sleepManager.parseSleepData()
        
        Chart(data) { segment in
            BarMark(
                xStart: .value("Start", segment.start),
                xEnd: .value("End", segment.end),
//                yStart: .value("Stage Start", yStart(for: segment.type)),
//                yEnd: .value("Stage End", yEnd(for: segment.type))
            )
            .foregroundStyle(color(for: segment.type))
            .cornerRadius(4)
        }
        .chartYAxis {
            AxisMarks(values: [0.0, 1.0, 2.0, 3.0, 4.0]) { value in
                if let v = value.as(Double.self) {
                    AxisValueLabel(stageName(for: Int(v)))
                }
            }
        }
        .frame(height: 240)
        .padding()
    }
    
    // MARK: - Vertical Ranges (Double to avoid compiler crash)
    func yStart(for type: SleepTypeNew) -> Double {
        switch type {
        case .deep: return 0
        case .light: return 1
        case .rem: return 2
        case .awake: return 3
        }
    }
    
    func yEnd(for type: SleepTypeNew) -> Double {
        switch type {
        case .deep: return 1
        case .light: return 2
        case .rem: return 3
        case .awake: return 4
        }
    }

    // MARK: - Labels
    func stageName(for value: Int) -> String {
        switch value {
        case 4: return "Awake"
        case 3: return "REM"
        case 2: return "Light"
        case 1: return "Deep"
        default: return ""
        }
    }

    // MARK: - Colors
    func color(for type: SleepTypeNew) -> Color {
        switch type {
        case .awake: return .yellow
        case .light: return .blue.opacity(0.4)
        case .deep: return .blue
        case .rem: return .purple
        }
    }
}
