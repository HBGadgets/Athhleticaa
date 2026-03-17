//
//  HeartRateScreenViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 07/03/26.
//

import SwiftUI

struct HeartRateScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
//    @ObservedObject var heartRateManager: HeartRateManager
    @State private var isMeasuring = false
    @State private var animateHeart = false
    @State private var showCalendar = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    @State private var goToInfoScreen = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Heart Rate Section
                if let dataList = ringManagerPro.dashboardDetailsData {
                    Text("\(dataList.count) items  got and last BPM is \(dataList.last?.heartRate) at \(dataList.last?.time)")
                    HeartRateHealthChartViewPro(
                        data: ringManagerPro.dashboardDetailsData ?? []
                    )
                    .padding(10)
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                    .frame(height: 250)
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
}
