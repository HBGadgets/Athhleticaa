//
//  SleepAnalysisScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI
import SwiftUI
import Charts
import SleepChartKit


struct SleepScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var sleepManagerPro: SleepManagerPro
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var showCalendar = false
    @State private var goToInfoScreen = false
    
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
                            Text(ringManagerPro.selectedDate, formatter: dateFormatter)
                                .font(.headline)
                                .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                        }
                        .sheet(isPresented: $showCalendar) {
                            WeeklyCalendarViewPro(ringManagerPro: ringManagerPro, fromScreen: "SleepAnalysisScreenPro")
                                .presentationDetents([.height(500)]) // Only as tall as needed
                                .presentationDragIndicator(.visible)
                        }
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
//                    SleepSummaryView(summary: sleepManagerPro.sleepSummary ?? Summary(totalMinutes: 0, startTime: Date(), endTime: Date(), efficiency: 0, quality: "Unknown", score: 0))
//                    SleepSummaryChartView(sleepManager: sleepManagerPro)
                    VStack(spacing: 20) {
                        if sleepManagerPro.sleepSegments.isEmpty {
                            Text("No data…")
                        } else {
                            let samples = sleepManagerPro.sleepSegments.map { segment in
                                SleepSample(
                                    stage: {
                                        switch segment.type {
                                        case .awake: return .awake
                                        case .light: return .asleepCore
                                        case .deep: return .asleepDeep
                                        case .rem: return .asleepREM
                                        }
                                    }(),
                                    startDate: segment.start,
                                    endDate: segment.end
                                )
                            }
                            
                            Text("\(sleepManagerPro.sleepSummary?.totalMinutes)")

                            SleepChartView(
                                samples: samples,
//                                colorProvider: MyColorProvider()
                            ).frame(height: 100)
                        }
                    }
                    .padding()
                    
                    ///
//                    SleepChartViewNew(sleepManager: ringManager.sleepManagerNew)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sleep Track").font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    goToInfoScreen = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                }
            }
        }
        .onAppear() {
            sleepManagerPro.readSleepDataForToday()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToInfoScreen) {
            SleepInfoScreen()
        }
    }
}
