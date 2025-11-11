//
//  BloodOxygenDataDetailScreenView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/11/25.
//

import SwiftUI

struct BloodOxygenDataDetailScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @State private var isSyncing = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if !ringManager.bloodOxygenManager.readings.isEmpty {
                    LazyVStack(spacing: 10) {
                        ForEach(ringManager.bloodOxygenManager.validBloodOxygenModels) { reading in
                            BloodOxygenCardView(
                                soa2: reading.soa2,
                                max: reading.maxSoa2,
                                min: reading.minSoa2,
                                type: reading.soa2Type,
                                time: reading.date
                            )
                        }
                    }
                    .padding()
                } else {
                    Text("No Stress data available")
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
                    ringManager.bloodOxygenManager.fetchBloodOxygenData() {
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
struct BloodOxygenCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var soa2: Double
    var max: Double
    var min: Double
    var type: BloodOxygenType
    var time: Date

    var body: some View {
        HStack {
            Image(systemName: "lungs.fill")
                .foregroundColor(.blue)
            Text("Max: \(Int(max)) | Min: \(Int(min))")
                .font(.headline)

            Spacer()

            Text(time.formatted(date: .omitted, time: .shortened))
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
