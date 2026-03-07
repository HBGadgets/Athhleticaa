//
//  BloodOxygenDetailsScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/11/25.
//

import SwiftUI

struct BloodOxygenScreenViewPro: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM yyyy"
        return formatter
    }
    
    
    private func levelString(stress: Int) -> String {
        switch stress {
        case 0..<29:
            return "Low"
        case 30..<59:
            return "Normal"
        case 60..<79:
            return "Normal"
        default:
            return "High"
        }
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(colorScheme == .light ? .black : .white))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Blood Oxygen").font(.headline)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
