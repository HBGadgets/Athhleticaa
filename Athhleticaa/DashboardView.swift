//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI

struct HealthDashboardView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Profile & Notification Row
                HStack {
                    Image("profile") // replace with your image name
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .overlay(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8),
                                alignment: .topTrailing
                            )
                    }
                }
                .padding(.horizontal)
                
                // Heart Rate Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("86")
                            .font(.system(size: 48, weight: .bold))
                        Text("bpm")
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.2))
                        .frame(height: 50)
                        .overlay(Text("❤️ ECG graph here").foregroundColor(.red.opacity(0.5)))
                }
                .padding()
                .background(Color.black)
                .cornerRadius(20)
                .foregroundColor(.white)
                .padding(.horizontal)
                
                // Steps Card
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("16 686")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("steps")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "figure.walk")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // Battery + Sleep Row
                HStack(spacing: 20) {
                    // Battery Card
                    VStack {
                        Text("16%")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("charge")
                            .foregroundColor(.gray)
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            Circle()
                                .trim(from: 0, to: 0.16)
                                .stroke(Color.red, lineWidth: 8)
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 60, height: 60)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                    
                    // Sleep Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Time asleep")
                            .foregroundColor(.gray)
                        Text("6 h 38 m")
                            .font(.title3)
                            .fontWeight(.bold)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 40)
                            .overlay(Text("Sleep chart").foregroundColor(.green.opacity(0.6)))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                
                // Achievements Gauge
                VStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .trim(from: 0.0, to: 0.75)
                            .stroke(Color.green, lineWidth: 15)
                            .rotationEffect(.degrees(135))
                        
                        Circle()
                            .trim(from: 0.75, to: 1.0)
                            .stroke(Color.red, lineWidth: 15)
                            .rotationEffect(.degrees(135))
                    }
                    .frame(width: 150, height: 150)
                    
                    Text("1806 poi")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Your achievements")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // Bottom Nav (Mock)
                HStack(spacing: 40) {
                    ForEach(["house.fill", "moon.fill", "heart.fill", "timer"], id: \.self) { icon in
                        Button(action: {}) {
                            Image(systemName: icon)
                                .font(.system(size: 22))
                                .foregroundColor(icon == "heart.fill" ? .red : .black)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(40)
                .shadow(radius: 4)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
