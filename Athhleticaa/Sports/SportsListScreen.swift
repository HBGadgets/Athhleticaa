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
        .init(title: "Spinning bike", icon: "spinningBike", sportType: .spinningBike),
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
        .init(title: "Battle rope", icon: "", sportType: .battleRope),
        .init(title: "Fitness sports", icon: "", sportType: .fitness),
        .init(title: "Balance training", icon: "", sportType: .balanceTraining),
        .init(title: "Step training", icon: "figure.step.training", sportType: .stepTraining),
        .init(title: "Square dance", icon: "", sportType: .squareDance),
        .init(title: "Ballroom dance", icon: "figure.socialdance", sportType: .ballroomDancing),
        .init(title: "Belly dance", icon: "", sportType: .bellyDance),
        .init(title: "Ballet", icon: "", sportType: .ballet),
        .init(title: "Hip-hop", icon: "", sportType: .hipHopDance),
        .init(title: "Zumba", icon: "", sportType: .zumba),
        .init(title: "Latin dance", icon: "", sportType: .latinDance),
        .init(title: "Jazz dance", icon: "", sportType: .latinJazz),
        .init(title: "Hip hop dance", icon: "", sportType: .hipHopDance),
        .init(title: "Pole dance", icon: "", sportType: .poleDancing),
        .init(title: "Break dance", icon: "", sportType: .breakDance),
        .init(title: "Folk dance", icon: "", sportType: .folkDance),
        .init(title: "Music dance", icon: "figure.dance", sportType: .dance),
        .init(title: "Modern dance", icon: "", sportType: .modernDance),
        .init(title: "Disco", icon: "", sportType: .disco),
        .init(title: "Tap dance", icon: "", sportType: .tapDance),
        .init(title: "Other dances", icon: "", sportType: .otherDance),
        .init(title: "Boxing", icon: "figure.boxing", sportType: .boxing),
        .init(title: "Wrestling", icon: "figure.wrestling", sportType: .wrestling),
        .init(title: "Martial arts", icon: "figure.martial.arts", sportType: .martialArts),
        .init(title: "Tai chi", icon: "figure.taichi", sportType: .taiChi),
        .init(title: "Muay thai", icon: "", sportType: .muayThai),
        .init(title: "Judo", icon: "", sportType: .judo),
        .init(title: "Taekwondo", icon: "", sportType: .taekwondo),
        .init(title: "Karate", icon: "", sportType: .karate),
        .init(title: "Swordsmanship", icon: "", sportType: .swordsmanship),
        .init(title: "Jujitsu", icon: "", sportType: .jujitsu),
        .init(title: "Fencing", icon: "figure.fencing", sportType: .fencing),
        .init(title: "Kendo", icon: "", sportType: .kendo),
        .init(title: "Beach soccer", icon: "figure.outdoor.soccer", sportType: .beachFootball),
        .init(title: "Beach volleyball", icon: "", sportType: .beachVolleyball),
        .init(title: "Baseball", icon: "figure.baseball", sportType: .baseball),
        .init(title: "Softball", icon: "figure.softball", sportType: .softball),
        .init(title: "Rugby football", icon: "figure.rugby", sportType: .newFootball),
        .init(title: "Hockey", icon: "figure.field.hockey", sportType: .hockey),
        .init(title: "Sqaush", icon: "figure.squash", sportType: .squash),
        .init(title: "Cricket", icon: "figure.cricket", sportType: .cricket),
        .init(title: "Handball", icon: "figure.handball", sportType: .handball),
        .init(title: "Bowling ball", icon: "figure.bowling", sportType: .bowling),
        .init(title: "Polo", icon: "", sportType: .polo),
        .init(title: "Billiards", icon: "", sportType: .billiards),
        .init(title: "Takraw ball", icon: "", sportType: .takraw),
        .init(title: "Dodgeball", icon: "", sportType: .dodgeBall),
        .init(title: "Water polo", icon: "", sportType: .waterPolo),
        .init(title: "Shuttlecock", icon: "", sportType: .shuttlecock),
        .init(title: "Indoor Football", icon: "", sportType: .indoorSoccer),
        .init(title: "Sandbag", icon: "", sportType: .sandbag),
        .init(title: "Bocce", icon: "", sportType: .bocce),
        .init(title: "Floor ball", icon: "", sportType: .floorBall),
        .init(title: "Australian rules football", icon: "figure.australian.football", sportType: .australianRulesFootball),
        .init(title: "Outdoor rowing", icon: "figure.indoor.rowing", sportType: .rowingMachine),
        .init(title: "Sailboat", icon: "figure.sailing", sportType: .sailing),
        .init(title: "Dragon boat", icon: "", sportType: .dragonBoat),
        .init(title: "Surfing", icon: "figure.surfing", sportType: .surf),
        .init(title: "Kitesurfing", icon: "", sportType: .kitesurfing),
        .init(title: "Paddle", icon: "", sportType: .paddling),
        .init(title: "Paddleboard", icon: "", sportType: .paddleboard),
        .init(title: "Indoor surf", icon: "", sportType: .indoorSurfing),
        .init(title: "Drift", icon: "", sportType: .drifting),
        .init(title: "Snorkel", icon: "", sportType: .snorkeling),
        .init(title: "Skis", icon: "figure.snowboarding", sportType: .snowboard),
        .init(title: "Alpine skiing", icon: "", sportType: .alpineSkiing),
        .init(title: "Cross country skiing", icon: "figure.skiing.crosscountry", sportType: .crossCountrySkiing),
        .init(title: "Outdoor skating", icon: "", sportType: .outdoorSkating),
        .init(title: "Indoor skating", icon: "", sportType: .indoorSkating),
        .init(title: "Curling", icon: "figure.curling", sportType: .curling),
        .init(title: "Bobsleigh", icon: "", sportType: .bobsleigh),
        .init(title: "Sled", icon: "", sportType: .sled),
        .init(title: "Snowmobile", icon: "", sportType: .snowmobile),
        .init(title: "Snowsport", icon: "", sportType: .snowboard),
        .init(title: "Hula hoop", icon: "", sportType: .hulaHoop),
        .init(title: "Flying disc", icon: "", sportType: .frisbee),
        .init(title: "Darts", icon: "", sportType: .darts),
        .init(title: "Kite flying", icon: "", sportType: .flyAKite),
        .init(title: "Tug of war", icon: "", sportType: .tugOfWar),
        .init(title: "E-sports", icon: "", sportType: .esports),
        .init(title: "Swing", icon: "", sportType: .swing),
        .init(title: "Shuffleboard", icon: "", sportType: .shuffleboard),
        .init(title: "Table football", icon: "", sportType: .tableSoccer),
        .init(title: "Somatosensory game", icon: "", sportType: .somatosensoryGame),
        .init(title: "Bungee jumping", icon: "", sportType: .bungeeJumping),
        .init(title: "Anusara", icon: "", sportType: .anusara),
        .init(title: "Yin yoga", icon: "", sportType: .yinYoga),
        .init(title: "Pregnancy yoga", icon: "", sportType: .pregnancyYoga),
        .init(title: "Chess", icon: "", sportType: .internationalChess),
        .init(title: "Go", icon: "", sportType: .go),
        .init(title: "Checkers", icon: "", sportType: .checkers),
        .init(title: "Board game", icon: "", sportType: .boardGame),
        .init(title: "Bridge", icon: "", sportType: .bridge),
        .init(title: "Triathlon", icon: "", sportType: .triathlon),
        .init(title: "Archery", icon: "figure.archery", sportType: .archery),
        .init(title: "Compound sport", icon: "", sportType: .compoundMovement),
        .init(title: "Drive", icon: "", sportType: .drive),
        .init(title: "Other sports", icon: "arrowshape.forward", sportType: .otherExtension),
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
                
                Image.safeIcon(icon)
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

extension Image {
    static func safeIcon(_ name: String) -> Image {
        if UIImage(systemName: name) != nil {
            return Image(systemName: name)
        } else {
            return Image(name) // uses asset image
        }
    }
}
