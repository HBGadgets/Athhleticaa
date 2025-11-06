//
//  HeartRateScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUICore
import SwiftUI

import SwiftUI

import SwiftUI

struct HeartRateScreenView: View {
    @ObservedObject var ringManager: QCCentralManager
    @StateObject var heartRateManager = HeartRateManager()
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false

    var body: some View {
        VStack(spacing: 20) {
//            HeartRateChartView(manager: heartRateManager)

            VStack(spacing: 16) {
                HStack {
                    Text("Real-time heart rate")
                        .font(.headline)
                    Spacer()
                    ZStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.red)
                            .scaleEffect(animateHeart ? 1.3 : 1.0)
                            .animation(
                                isMeasuring
                                ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                : .default,
                                value: animateHeart
                            )
                    }
                    Text(currentHeartRate != nil ? "\(currentHeartRate!) bpm" : "-- bpm")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                Button(action: {
                    if !isMeasuring {
                        // Start measuring
                        isMeasuring = true
                        currentHeartRate = nil
//                        ringManager.measureHeartRate()
                        animateHeart = true
                    } else {
                        // Stop measuring
                        isMeasuring = false
                        currentHeartRate = nil
                        animateHeart = false
                    }
                }) {
                    Text(isMeasuring ? "Measuring..." : "Click to start measurement")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMeasuring ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .disabled(isMeasuring) // prevent rapid taps
            }
            .padding()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .onReceive(ringManager.$heartRate) { newValue in
            guard let hr = newValue else { return }
            currentHeartRate = hr
            isMeasuring = false
            animateHeart = false
        }
        .onChange(of: isMeasuring) { measuring in
            if measuring {
                withAnimation {
                    animateHeart = true
                }
            } else {
                animateHeart = false
            }
        }
        .padding()
    }
}
