//
//  SleepAnalysisScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUICore
import SwiftUI
import Charts

struct SleepStageData: Identifiable {
    let id = UUID()
    let type: SleepType
    let totalMinutes: Int
}


struct SleepsAnalysisScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var sleepManager: SleepManager

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    SleepSummaryView(summary: sleepManager.summary ?? Summary(totalMinutes: 0, startTime: Date(), endTime: Date(), efficiency: 0, quality: "Unknown", score: 0))
                    SleepSummaryChartView(sleepManager: sleepManager)
                    SleepChartViewContainer(sleepManager: sleepManager)
                }
                .padding(.bottom, 70)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sleep Track").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
