//
//  RingConnectViewPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 10/03/26.
//

import SwiftUI

struct RingConnectViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    
    var body: some View {
        ZStack (alignment: .leading) {
            GeometryReader { geo in
                Image("RingImage")
                    .resizable()
                    .rotationEffect(.degrees(125))
                    .scaledToFill()
                    .frame(width: 180, height: 180, alignment: .leading)
                    .clipped()
                    .opacity(0.3)
                    .offset(x: -geo.size.width * 0.15)
            }
            HStack {
                Image("RingImage")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(-75))
                    .frame(width: 120, height: 120)
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .cornerRadius(12)
                    .padding(.leading, 20)
                
                Spacer()

                if let device = ringManagerPro.connectedPeripheral {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(device.name ?? "Unknown")")
                            .font(.title3)
                            .bold()
                        
                        Text("• Connected")
                            .foregroundStyle(.green)
                        
//                        HStack {
//                            Text("Battery: \(ringManagerPro.batteryLevel ?? 0)%")
//                            if (ringManagerPro.isCharging) {
//                                Image(systemName: "bolt.fill")
//                                    .foregroundStyle(.green)
//                            }
//                        }
                        
//                        Button("Unbind") {
//                            ringManagerPro.disconnect()
//                        }
//                        .backgroundStyle(.blue)
//                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Device not connected")
                            .font(.title3)
                            .bold()

                        NavigationLink(destination: ScanningScreenPro(ringManager: ringManagerPro)) {
                            Text("Scan for ring")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
                
            }
        }
        .clipped()
//                .padding()
        .background(colorScheme == .light ? Color.white : Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.3)
    }
}
