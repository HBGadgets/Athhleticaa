//
//  SportsCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 26/11/25.
//

import SwiftUI
import Charts
import SleepChartKit


// MARK: - Sleep
struct SportsCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                Image("SportsCardImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped() // ✅ crops inside bounds
                    .overlay(
                        Color.black.opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .allowsHitTesting(false) // so image doesn’t block taps

            VStack {
                VStack(spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sports")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .fontWidth(.expanded)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    
                    HStack(alignment: .center) {
                        Image(systemName: "figure.basketball")
                            .font(.system(size: 70, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        NavigationLink (destination: SportsListScreen(ringManager: ringManager)) {
                            Text("GO!")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(height: 230)
    }
}
