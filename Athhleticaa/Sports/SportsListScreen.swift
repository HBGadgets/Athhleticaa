//
//  SportsListScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI

struct SportsListScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    var body: some View {
        ScrollView {
            VStack {
                SportActivityItem(title: "Run", icon: "figure.run", sportType: .run, ringManager: ringManager)
                SportActivityItem(title: "Bike", icon: "bicycle", sportType: .bike, ringManager: ringManager)
                SportActivityItem(title: "Walk", icon: "figure.walk", sportType: .walk, ringManager: ringManager)
                SportActivityItem(title: "Hiking", icon: "figure.hiking", sportType: .hiking, ringManager: ringManager)
                SportActivityItem(title: "Spinning bike", icon: "", sportType: .spinningBike, ringManager: ringManager)
                SportActivityItem(title: "Rope skipping", icon: "figure.jumprope", sportType: .ropeSkipping, ringManager: ringManager)
                SportActivityItem(title: "Swimming", icon: "figure.pool.swim", sportType: .swimming, ringManager: ringManager)
                SportActivityItem(title: "Eliptical machine", icon: "", sportType: .ellipticalMachine, ringManager: ringManager)
                SportActivityItem(title: "Yoga", icon: "figure.yoga", sportType: .yoga, ringManager: ringManager)
                SportActivityItem(title: "Basketball", icon: "figure.basketball", sportType: .basketball, ringManager: ringManager)
                SportActivityItem(title: "Volleyball", icon: "figure.volleyball", sportType: .volleyball, ringManager: ringManager)
                SportActivityItem(title: "Badminton", icon: "figure.badminton", sportType: .badminton, ringManager: ringManager)
                SportActivityItem(title: "Aerobics", icon: "figure.highintensity.intervaltraining", sportType: .aerobics, ringManager: ringManager)
                SportActivityItem(title: "Kayaking", icon: "", sportType: .kayaking, ringManager: ringManager)
                SportActivityItem(title: "Roller skating", icon: "figure.ice.skating", sportType: .rollerSkating, ringManager: ringManager)
                SportActivityItem(title: "Tennis", icon: "figure.tennis", sportType: .tennis, ringManager: ringManager)
                SportActivityItem(title: "Football", icon: "figure.australian.football", sportType: .football, ringManager: ringManager)
                SportActivityItem(title: "Golf", icon: "figure.golf", sportType: .golf, ringManager: ringManager)
                SportActivityItem(title: "PingPong", icon: "figure.table.tennis", sportType: .pingpong, ringManager: ringManager)
                SportActivityItem(title: "Dance", icon: "figure.dance", sportType: .dance, ringManager: ringManager)
                SportActivityItem(title: "Rock climbing", icon: "figure.climbing", sportType: .rockClimbing, ringManager: ringManager)
                SportActivityItem(title: "Treadmill", icon: "figure.walk.treadmill", sportType: .treadmill, ringManager: ringManager)
            }
            .padding(.horizontal)
        }
        .navigationTitle(Text("Sports mode"))
    }
}

struct SportActivityItem: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var icon: String
    var sportType: OdmSportPlusExerciseModelType
    @ObservedObject var ringManager: QCCentralManager

    var body: some View {
        NavigationLink (destination: SportActivityScreen(sportType: sportType, ringManager: ringManager)) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(.blue.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
            }
            .frame(height: 50) // <- keeps everything perfectly centered
            .padding()
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)

        }
        .buttonStyle(.plain)
    }
}
