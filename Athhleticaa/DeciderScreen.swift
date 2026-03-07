//
//  DeciderScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 06/03/26.
//

import SwiftUI

struct DeciderScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var goToPro = false
    @State private var goToNonPro = false
    @State private var showUserInfoSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingItem(
                    title: "Go to Pro",
                )
                .onTapGesture {
                    print("go to pro tapped")
                    
                    if UserProfileStorage.load() == nil {
                        showUserInfoSheet = true
                    } else {
                        goToPro = true
                    }
                }
                
                SettingItem(
                    title: "Go to Non Pro",
                )
                .onTapGesture {
                    print("go to non pro tapped")
                    goToNonPro = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToPro) {
            ContentViewPro()
        }
        .navigationDestination(isPresented: $goToNonPro) {
            ContentViewNonPro()
        }
        .sheet(isPresented: $showUserInfoSheet) {
                    NavigationStack {
                        UserInformationScreenView()
                    }
                }
    }
}

