//
//  ActivityInfoScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/12/25.
//

import SwiftUI

struct ActivityInfoScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
//                Text("""
//                Total Steps
//                Daily steps are a simple way to track overall movement and activity. A higher daily step count generally reflects a more active lifestyle. Many people aim for a daily step goal to stay active, which can be adjusted based on personal fitness levels and routines.
//
//                Total Calories
//                Total calories represent the estimated energy burned throughout the day from all activities, including walking, exercise, and general movement. Tracking this value over time can help users understand their activity patterns and support their fitness goals.
//
//                Note
//                This software and the associated smart ring device are not medical devices; provided fitness-related information intended for general wellness and activity tracking only. It is not intended for medical use.
//                """)
                Text("""
                Note
                This software and the associated smart ring device are not medical devices; provided fitness-related information intended for general wellness and activity tracking only. It is not intended for medical use.
                """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Activity Description").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
