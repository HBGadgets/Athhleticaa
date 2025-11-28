//
//  SportActivityScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI

struct SportActivityScreen: View {
    @Environment(\.colorScheme) var colorScheme
    var sportType: SportActivity

    @State var stopped: Bool = false
    @ObservedObject var ringManager: QCCentralManager
    @ObservedObject var sportsManager: SportsManager
    @State private var goToActivityListScreen = false

    init(ringManager: QCCentralManager) {
        self.ringManager = ringManager
        self.sportsManager = ringManager.sportsManager
        self.sportType = ringManager.sportsManager.currentSportType!
    }
    
    func formatSecondsToHMS(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                
                
                // MARK: - Steps
                VStack(spacing: 8) {
                    // MARK: - Activity Title
                    HStack {
                        Image.safeIcon(sportType.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(.blue.opacity(0.1))
                            .clipShape(Circle())

                        Text(sportType.title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("\(sportsManager.currentSteps)")
                        .font(.system(size: 38, weight: .medium))
                    
                    Text("Steps")
                        .font(.system(size: 16))
                }
                
                // MARK: - Timer
                Text(formatSecondsToHMS(sportsManager.currentSeconds))
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Metrics Row
                HStack(spacing: 60) {
                    VStack {
                        Text("\(sportsManager.currentHeartRate)")
                            .font(.system(size: 22, weight: .medium))
                        Text("bpm")
                            .font(.system(size: 14))
                    }
                    
                    VStack {
                        Text("\(sportsManager.currentDistance)")
                            .font(.system(size: 22, weight: .medium))
                        Text("Km")
                            .font(.system(size: 14))
                    }
                    
                    VStack {
                        Text("\(sportsManager.currentCalorie)")
                            .font(.system(size: 22, weight: .medium))
                        Text("Kcal")
                            .font(.system(size: 14))
                    }
                }
                
                Spacer()
                
                // MARK: - Bottom Section
                if (stopped) {
                    HStack {
                        Button(action: {
                            sportsManager.stopSport(type: sportType.sportType){
//                                goToActivityListScreen = true
                            }
                        }) {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 8)
                        }
                        .padding(.bottom, 40)
                        
                        Spacer()
                        
                        Button(action: {
                            sportsManager.resumeSport(type: sportType.sportType) {
                                stopped = false
                            }
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 8)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 15)
                } else {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Pause Button
                    Button(action: {
                        sportsManager.pauseSport(type: sportType.sportType) {
                            stopped = true
                        }
                    }) {
                        Image(systemName: "pause.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 40))
                            .frame(width: 80, height: 80)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .padding(.bottom, 40)
                }
                
            }
        }
        .onAppear() {
            sportsManager.startSport(type: sportType.sportType) {
                DispatchQueue.main.async {
                    sportsManager.updateData()
                }
            }
        }
        .statusBar(hidden: true)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
//        .navigationDestination(isPresented: $goToActivityListScreen) {
//            SportsListScreen(ringManager: ringManager)
//        }
    }
}
