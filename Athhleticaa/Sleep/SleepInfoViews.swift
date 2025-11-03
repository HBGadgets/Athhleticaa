//
//  SleepInfoViews.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI
import SleepChartKit

struct SleepChartViewContainer: View {
    @ObservedObject var sleepManager: SleepManager
    
    var body: some View {
        VStack(spacing: 20) {
            if sleepManager.sleepSegments.isEmpty {
                Text("Loading sleep data…")
            } else {
                // Convert your segments into SleepSample
                let samples = sleepManager.sleepSegments.map { segment in
                    SleepSample(
                        stage: {
                            switch segment.type {
                            case .awake:     return .awake
                            case .light:    return .asleepCore
                            case .deep:     return .asleepDeep
                            case .rem:      return .asleepREM
                            }
                        }(),
                        startDate: segment.startTime,
                        endDate: segment.endTime
                    )
                }

                SleepChartView(samples: samples)
                    .frame(height: 200)
                
                HStack {
                    ForEach([SleepType.light, .deep, .rem], id: \.self) { type in
                        Label(type.label, systemImage: "circle.fill")
                            .foregroundColor(type.color)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}
