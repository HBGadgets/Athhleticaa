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
