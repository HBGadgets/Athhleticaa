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
    @StateObject var sleepManager = SleepManager()

    var body: some View {
        ZStack {
            ScrollView {
                if sleepManager.summary == nil {
                    ProgressView("Loading data")
                        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                        .scaleEffect(1.2)
                    Text("Please wait...")
                } else {
                    VStack(spacing: 20) {
                        SleepSummaryView(summary: sleepManager.summary!)
                        SleepSummaryChartView(sleepManager: sleepManager)
                        SleepChartViewContainer(sleepManager: sleepManager)
                    }
                    .padding(.bottom, 70)
                }
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
