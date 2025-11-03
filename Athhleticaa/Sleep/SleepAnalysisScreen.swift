//
//  SleepAnalysisScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUICore
import SwiftUI

struct SleepsAnalysisScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var sleepManager: SleepManager

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
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                SleepChartViewContainer(sleepManager: sleepManager)
            }
        }
        .onAppear {
            sleepManager.getSleepFromDay(day: 0)
        }
    }
}
