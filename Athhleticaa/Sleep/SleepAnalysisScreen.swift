//
//  SleepAnalysisScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUICore
import SwiftUI

struct SleepsAnalysisScreenView: View {
    @StateObject var sleepManager = SleepManager()

    var body: some View {
        ZStack {
            ScrollView {
                SleepChartViewContainer(sleepManager: sleepManager)
            }
        }
        .onAppear {
            sleepManager.getSleepFromDay(day: 0)
        }
    }
}
