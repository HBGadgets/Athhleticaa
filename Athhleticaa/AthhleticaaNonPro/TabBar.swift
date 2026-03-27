//
//  TabBar.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 02/11/25.
//

import SwiftUI


struct TabBar: View {
    @ObservedObject var ringManager: QCCentralManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<5) { index in
                tabButton(for: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .modifier(GlassCardModifier(cornerRadius: 100))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        
        .alert(
            "Low Battery",
            isPresented: Binding(
                get: {
                    ringManager.showLowBatteryAlert && ringManager.lowBatteryAlert
                },
                set: { _ in
                    
                }
            )
        ) {
            Button("OK", role: .cancel) {
                ringManager.showLowBatteryAlert = false
            }
        } message: {
            Text(ringManager.lowBatteryMessage)
        }
    }

    @ViewBuilder
    func tabButton(for index: Int) -> some View {
        let icons = ["house.fill", "heart.fill", "shoeprints.fill", "moon.fill", "person.crop.circle"]
        let isSelected = ringManager.selectedTab == index

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                ringManager.selectedTab = index
            }
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                colorScheme == .dark ?
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                :
                Image(systemName: icons[index])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black)
            }
        }
    }
}

