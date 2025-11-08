//
//  DataDetailsScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 08/11/25.
//

import SwiftUI

struct HeartRateDataDetailScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @State private var isSyncing = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if let data = ringManager.heartRateManager.dayData.first {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(data.heartRates.enumerated().reversed()), id: \.offset) { index, bpm in
                            if bpm > 0, let time = data.timeForHeartRate(at: index) {
                                HeartRateCardView(bpm: bpm, time: time)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("No heart rate data available")
                        .foregroundStyle(.gray)
                        .padding()
                }
            }
            if isSyncing {
                VStack(spacing: 20) {
                    ProgressView("Syncing data")
                        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                        .scaleEffect(1.2)
                    Text("Please wait...")
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Data Details")
                    .font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isSyncing = true
                    ringManager.heartRateManager.fetchTodayHeartRate() {
                        isSyncing = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Card View
struct HeartRateCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let bpm: Int
    let time: Date
    
    // Define the formatter once
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    var body: some View {
        HStack {
            HStack() {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(bpm) BPM")
                    .font(.headline)
            }
            
            Spacer()
            
            Text(Self.formatter.string(from: time))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
