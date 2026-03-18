//
//  HRVScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI

import SwiftUI
import Charts

struct HRVScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }
    
    var body: some View {
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
                        WeeklyCalendarViewPro(ringManagerPro: ringManagerPro, fromScreen: "HRVScreenPro")
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("HRV").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
