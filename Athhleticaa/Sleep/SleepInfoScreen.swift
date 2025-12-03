//
//  SleepInfoScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 03/12/25.
//

import SwiftUI

struct SleepInfoScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("About Sleep Tracking")
                    .font(.title2)
                    .bold()
                
                Text("""
                Sleep tracking helps you understand patterns such as time spent sleeping, estimated sleep duration, and general rest consistency. These insights may help you maintain healthier routines, improve recovery, and recognize how daily habits affect rest.
                
                Different factors such as lifestyle, schedule, and environment can influence sleep patterns. Sleep data varies from person to person and should be used as a general guide to support your wellness goals.
                """)
                .foregroundColor(.secondary)
                .font(.body)
                
                Divider()
                
                Text("""
                Disclaimer:
                Sleep information in this app is intended for general wellness and personal insights only. It is not intended for medical use or to diagnose, treat, or monitor any medical conditions.
                """)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(colorScheme == .light ? .white : Color(.systemGray6)))
            .cornerRadius(16)
            .padding()
        }
        .navigationTitle("Sleep Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}
