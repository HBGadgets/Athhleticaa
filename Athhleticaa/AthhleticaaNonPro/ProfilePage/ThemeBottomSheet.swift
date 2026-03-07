//
//  ThemeBottomSheet.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 12/11/25.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light Mode"
    case dark = "Dark Mode"
}

struct ThemeBottomSheet: View {
    @Binding var selectedTheme: AppTheme
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Theme")
                .font(.headline)
            
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button {
                    selectedTheme = theme
                    applyTheme(theme)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: selectedTheme == theme ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.accentColor)
                        Text(theme.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .presentationDetents([.fraction(0.3)]) // bottom sheet height
    }
    
    private func applyTheme(_ theme: AppTheme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else { return }
        
        switch theme {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
}
