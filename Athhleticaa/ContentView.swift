//
//  ContentView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 23/10/25.
//

import SwiftUI

import SwiftUI
import CoreBluetooth

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ringManager = QCCentralManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch ringManager.selectedTab {
                    case 0:
                        DashboardView(ringManager: ringManager)
                    case 1:
                        HeartRateScreenView(ringManager: ringManager)
                    case 2:
                        ActivityScreenView()
                    case 3:
                        SleepsAnalysisScreenView()
                    case 4:
                        StressAnalysisScreenView()
                    case 5:
                        ProfileView()
                    default:
                        DashboardView(ringManager: ringManager)
                    }
                }
                VStack {
                    Spacer()
                    TabBar(ringManager: ringManager)
                        .padding(.bottom, -10)
                }
                if !ringManager.dataLoaded {
                    VStack(spacing: 20) {
                        ProgressView("Syncing data")
                            .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                            .scaleEffect(1.2)
                        Text("Please wait...")
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    colorScheme == .dark ?
                    Image(.athhleticaaLogoDarkMode)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    :
                    Image(.athhleticaaLogoLightMode)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}
