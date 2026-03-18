//
//  SportActivityScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI

struct SportActivityScreenViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var goToPro = false
    @State private var goToNonPro = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingItem(
                    title: "Profile screen",
                )
                .onTapGesture {
                    goToPro = true
                }
            }
        }
    }
}
