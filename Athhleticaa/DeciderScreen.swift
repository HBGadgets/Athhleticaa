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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingItem(
                    title: "Go to Pro",
                )
                .onTapGesture {
                    print("go to pro tapped")
                    goToPro = true
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
    }
}

