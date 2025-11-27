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
    @State private var searchText = ""
    
    // MARK: - Sport activities
    let activities: [SportActivity] = [
        .init(title: "Run", icon: "figure.run", sportType: .run),
        .init(title: "Bike", icon: "bicycle", sportType: .bike),
        .init(title: "Walk", icon: "figure.walk", sportType: .walk),
        .init(title: "Hiking", icon: "figure.hiking", sportType: .hiking),
        .init(title: "Spinning bike", icon: "", sportType: .spinningBike),
        .init(title: "Rope skipping", icon: "figure.jumprope", sportType: .ropeSkipping),
        .init(title: "Swimming", icon: "", sportType: .swimming),
        .init(title: "Eliptical machine", icon: "", sportType: .ellipticalMachine),
        .init(title: "Yoga", icon: "figure.yoga", sportType: .yoga),
        .init(title: "Basketball", icon: "figure.basketball", sportType: .basketball),
        .init(title: "Volleyball", icon: "figure.volleyball", sportType: .volleyball),
        .init(title: "Badminton", icon: "figure.badminton", sportType: .badminton),
        .init(title: "Aerobics", icon: "figure.highintensity.intervaltraining", sportType: .aerobics),
        .init(title: "Kayaking", icon: "figure.outdoor.rowing", sportType: .kayaking),
        .init(title: "Roller skating", icon: "figure.ice.skating", sportType: .rollerSkating),
        .init(title: "Tennis", icon: "figure.tennis", sportType: .tennis),
        .init(title: "Football", icon: "figure.indoor.soccer", sportType: .football),
        .init(title: "Golf", icon: "figure.golf", sportType: .golf),
        .init(title: "PingPong", icon: "figure.table.tennis", sportType: .pingpong),
        .init(title: "Dance", icon: "figure.dance", sportType: .dance),
        .init(title: "Rock climbing", icon: "figure.climbing", sportType: .rockClimbing),
        .init(title: "Treadmill", icon: "figure.walk.treadmill", sportType: .treadmill),
        .init(title: "Indoor walking", icon: "figure.walk", sportType: .indoorWalking),
        .init(title: "Playground run", icon: "figure.run.motion", sportType: .playgroundRunning),
        .init(title: "Running for fat loss", icon: "figure.run.and.heart", sportType: .fatLossRunning),
        .init(title: "Outdoor cycling", icon: "figure.outdoor.cycle", sportType: .outdoorCycling),
        .init(title: "Indoor cycling", icon: "figure.indoor.cycle", sportType: .indoorCycling),
        .init(title: "Mountain Biking", icon: "", sportType: .mountainBiking),
        .init(title: "BMX", icon: "", sportType: .BMX),
        .init(title: "Pool Swimming", icon: "figure.pool.swim", sportType: .swimmingPool),
        .init(title: "Outdoor swimming", icon: "figure.open.water.swim", sportType: .outdoorSwimming),
        .init(title: "Finswimming", icon: "", sportType: .finSwimming),
        .init(title: "Outdoor walking", icon: "figure.hiking", sportType: .outdoorHiking),
        .init(title: "Orienteering", icon: "", sportType: .orienteering),
        .init(title: "Fishing", icon: "figure.fishing", sportType: .fishing),
        .init(title: "Hunting", icon: "figure.hunting", sportType: .hunt),
        .init(title: "Skateboarding", icon: "figure.skateboarding", sportType: .skateboard),
        .init(title: "Parkour", icon: "", sportType: .parkour),
        .init(title: "ATV", icon: "", sportType: .ATV),
        .init(title: "Motocross", icon: "motorcycle.fill", sportType: .motocross),
        .init(title: "Racing", icon: "", sportType: .racing),
        .init(title: "Crank car", icon: "", sportType: .handCrank),
        .init(title: "Marathon", icon: "", sportType: .marathon),
        .init(title: "Climbing stairs", icon: "figure.stairs", sportType: .stairClimber),
        .init(title: "Stepper", icon: "figure.stair.stepper", sportType: .stairStepper),
        .init(title: "Mixed aerobic", icon: "figure.mixed.cardio", sportType: .mixedAerobic),
        .init(title: "Kickboxing", icon: "figure.kickboxing", sportType: .kickboxing),
        .init(title: "Core training", icon: "figure.core.training", sportType: .coreTraining),
        .init(title: "Cross training", icon: "figure.cross.training", sportType: .crossTraining),
        .init(title: "Indoor fitness", icon: "", sportType: .indoorFitness),
        .init(title: "Group gymnastics", icon: "", sportType: .groupGymnastics),
        .init(title: "Strength training", icon: "figure.strengthtraining.traditional", sportType: .strengthTraining),
        .init(title: "Interval training", icon: "figure.highintensity.intervaltraining", sportType: .gapTraining),
        .init(title: "Free training", icon: "", sportType: .freeTraining),
        .init(title: "Flexibility Trainig", icon: "figure.flexibility", sportType: .flexibilityTraining),
        .init(title: "Gymnastics", icon: "figure.gymnastics", sportType: .gymnastics),
        .init(title: "Stretch", icon: "figure.strengthtraining.functional", sportType: .stretch),
        .init(title: "Pilates", icon: "figure.pilates", sportType: .pilates),
        .init(title: "Horizontal bar", icon: "", sportType: .horizontalBar),
        .init(title: "Dual bars", icon: "", sportType: .parallelBars),
        .init(title: "Battle rope", icon: "bicycle", sportType: .bike),
    ]

    var filteredActivities: [SportActivity] {
        if searchText.isEmpty { return activities }
        return activities.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredActivities) { item in
                    SportActivityItem(
                        title: item.title,
                        icon: item.icon,
                        sportType: item.sportType,
                        ringManager: ringManager
                    )
                }
            }
            .padding(.horizontal)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Sports")
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
            .padding(.horizontal)
            .padding(.vertical, 7)
            .background(colorScheme == .light ? Color.white : Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)

        }
        .buttonStyle(.plain)
    }
}
