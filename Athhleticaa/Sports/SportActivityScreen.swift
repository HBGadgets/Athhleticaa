//
//  SportActivityScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI

struct SportActivityScreen: View {
    @Environment(\.colorScheme) var colorScheme
    var sportType: OdmSportPlusExerciseModelType
    @ObservedObject var ringManager: QCCentralManager
    
    func showData () {
        QCSDKManager.shareInstance().currentSportInfo = { info in
            print("---- SPORT LIVE INFO ----")
            print("Type:", info.sportType)
            print("State:", info.state)
            print("Duration:", info.duration)
            print("HR:", info.hr)
            print("Steps:", info.step)
            print("Calorie:", info.calorie)
            print("Distance:", info.distance)
            print("-------------------------")
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("sportType: \(sportType)")
                        .font(.headline)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)
            .onAppear() {
                ringManager.sportsManager.startSport(type: sportType) {
                    QCSDKManager.shareInstance().currentSportInfo = { info in
                        print("---- SPORT LIVE INFO ----")
                        print("Type:", info.sportType)
                        print("State:", info.state)
                        print("Duration:", info.duration)
                        print("HR:", info.hr)
                        print("Steps:", info.step)
                        print("Calorie:", info.calorie)
                        print("Distance:", info.distance)
                        print("-------------------------")
                    }
                }
            }
            Button("Stop") {
                ringManager.sportsManager.stopSport(type: sportType)
            }
        }
        
    }
}
