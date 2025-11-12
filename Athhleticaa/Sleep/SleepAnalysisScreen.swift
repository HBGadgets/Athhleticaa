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
    @ObservedObject var ringManager: QCCentralManager
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Text(ringManager.selectedDate, formatter: dateFormatter)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showCalendar) {
                            WeeklyCalendarView(ringManager: ringManager, fromScreen: "SleepAnalysisScreen")
                                .presentationDetents([.height(500)]) // Only as tall as needed
                                .presentationDragIndicator(.visible)
                        }
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                    SleepSummaryView(summary: sleepManager.summary ?? Summary(totalMinutes: 0, startTime: Date(), endTime: Date(), efficiency: 0, quality: "Unknown", score: 0))
                    SleepSummaryChartView(sleepManager: sleepManager)
                    SleepChartViewContainer(sleepManager: sleepManager)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sleep Track").font(.headline)
            }
        }
        .onAppear() {
            ringManager.sleepManager.getSleep()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
