//
//  SleepCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct SleepCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var sleepManager: SleepManager
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "#b06510") : Color(hex: "#ff9214"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white, lineWidth: 0.7)
                        .blur(radius: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sleep")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(formattedToday)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(alignment: .center) {
                    if sleepManager.summary?.score != 0 {
                        let summary = sleepManager.summary
                                
                        TotalSleepRingView(totalMinutes: summary?.totalMinutes ?? 0)
                        
                        Spacer()
                        
                        VStack {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 70, weight: .semibold))
                            if let summaryScore = summary?.score {
                                Text("\(summaryScore)")
                                    .font(.headline)
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
                    
//                    if let summary = sleepManager.summary {
//                        TotalSleepRingView(totalMinutes: summary.totalMinutes)
//
//                        Spacer()
//
//                        VStack {
//                            Image(systemName: "moon.stars.fill")
//                                .font(.system(size: 70, weight: .semibold))
//                            Text("\(sleepManager.summary.score)")
//                                .font(.headline)
//                            Text("Sleep score")
//                                .font(.subheadline)
//                        }
//                        .foregroundColor(.white)
//                    } else {
//                        HStack {
//                            Image(systemName: "moon.stars.fill")
//                                .font(.system(size: 50, weight: .semibold))
//                            Text("No Data")
//                                .font(.system(size: 20, weight: .bold))
//                        }.foregroundColor(.white)
//                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(height: 250)

        
    }
}


struct TotalSleepRingView: View {
    let totalMinutes: Int
    let targetMinutes: Int = 480 // 8 hours goal
    
    var progress: Double {
        min(Double(totalMinutes) / Double(targetMinutes), 1.0)
    }
    
    private func formattedDuration(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return "\(h)h \(m)m"
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 20)
                .frame(width: 120, height: 120)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 120, height: 120)
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center text
            VStack(spacing: 6) {
                Text(formattedDuration(totalMinutes))
                    .font(.system(size: 18, weight: .bold))
                
                Text("Total Sleep")
                    .font(.caption)
            }
            .foregroundStyle(.white)
        }
    }
}
