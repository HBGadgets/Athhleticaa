//
//  SportsHistoryScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI

struct SportsHistoryScreen: View {
    @Environment(\.colorScheme) var colorScheme
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
                                .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                        }
                        .sheet(isPresented: $showCalendar) {
                            WeeklyCalendarView(ringManager: ringManager, fromScreen: "SportsHistoryScreen")
                                .presentationDetents([.height(500)]) // Only as tall as needed
                                .presentationDragIndicator(.visible)
                        }
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sports Record").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
