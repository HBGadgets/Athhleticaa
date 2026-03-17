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
                    
                    if let time = ringManagerPro.timeChartHeartRate {
                        HStack {
                            if let hb = ringManagerPro.heartRateValueChart {
                                Text("\(hb) BPM")
                            }
                            Text(time, format: .dateTime.hour().minute().hour(.twoDigits(amPM: .abbreviated)))
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    } else {
                        HStack {
                            Text("\(ringManagerPro.dashboardDetailsData?.last?.heartRate ?? 0) BPM")
                            Text({
                                if let data = ringManagerPro.dashboardDetailsData,
                                   let time = ringManagerPro.dashboardDetailsData?.last?.time {
                                   return time.toAMPM
                                } else {
                                    return "--:--"
                                }
                            }())
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    }
                    HeartRateHealthChartViewPro(
                        data: ringManagerPro.dashboardDetailsData ?? [],
                        ringManagerPro: ringManagerPro
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

extension String {
    var toAMPM: String {
        let parts = self.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return self }
        let suffix = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, suffix)
    }
}


