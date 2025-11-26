//
//  SportsCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct SportsCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                Image("SportsCardImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped() // ✅ crops inside bounds
                    .overlay(
                        Color.black.opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .allowsHitTesting(false) // so image doesn’t block taps

            VStack {
                VStack(spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sports")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .fontWidth(.expanded)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    
                    HStack(alignment: .center) {
                        if ringManager.dashboardSleepSummary?.score != 0 {
                            let summary = ringManager.dashboardSleepSummary
                                    
                            TotalSleepRingView(totalMinutes: summary?.totalMinutes ?? 0)
                            
                            Spacer()
                            
                            VStack {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 70, weight: .semibold))
                                if let summaryScore = summary?.score {
                                    Text("\(summaryScore)")
                                        .font(.headline)
                                        .fontWidth(.expanded)
                                } else {
                                    Text("...")
                                        .font(.headline)
                                }
                                
                                Text("Sleep score")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                        } else {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 50, weight: .semibold))
                                VStack {
                                    Text("No Data")
                                        .font(.system(size: 20, weight: .bold))
                                    Text("Wear smart ring during sleep to get sleep data")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                
                            }.foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(height: 230)
    }
}
