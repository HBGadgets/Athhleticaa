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
    @State private var goToCountDownScreen = false
    @State private var navigationTrigger = false
    
    var filteredActivities: [SportActivity] {
        if searchText.isEmpty { return ringManager.sportsManager.activities }
        return ringManager.sportsManager.activities.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    func formatSecondsToHMS(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredActivities) { item in
                    Button {
                        ringManager.sportsManager.currentSportType = item
                        goToCountDownScreen = true
                    } label: {
                        SportActivityItem(
                            title: item.title,
                            icon: item.icon,
                            sportType: item,
                            ringManager: ringManager
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Sports")
        .navigationDestination(isPresented: $goToCountDownScreen) {
            CountdownScreen(ringManager: ringManager)
        }
    }
}

struct SportActivityItem: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var icon: String
    var sportType: SportActivity
    @ObservedObject var ringManager: QCCentralManager

    var body: some View {
//        NavigationLink (destination: SportActivityScreen(ringManager: ringManager)) {
            HStack(alignment: .center, spacing: 12) {
                
                Image.safeIcon(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
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

//        }
//        .buttonStyle(.plain)
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

class NavigationRouter: ObservableObject {
    static let shared = NavigationRouter()

    @Published var resetToRoot: Bool = false

    func goToRoot() {
        resetToRoot = true
    }
}
