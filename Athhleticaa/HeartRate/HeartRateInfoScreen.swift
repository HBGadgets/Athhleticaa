//
//  HeartRateInfoScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/12/25.
//

import SwiftUI

struct HeartRateInfoScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - Heart Rate Range Title
                Text("Heart Rate Range")
                    .font(.system(size: 28, weight: .semibold))
                    .padding(.horizontal)
                
                // MARK: - Colored Range Table
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 1) {
                        labelRow("Limit")
                        labelRow("Anaerobic endurance")
                        labelRow("Aerobic endurance")
                        labelRow("Fat burning")
                        labelRow("Warm up")
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        valueRow("171", .red)
                        valueRow("152", .orange)
                        valueRow("133", .yellow)
                        valueRow("114", .green)
                        valueRow("95", .blue)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                
                // MARK: - Note Title
                VStack(alignment: .leading, spacing: 12) {
                    Text("Heart Rate Range Note")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text("Heart rate range = (220 - age) * maximum heart rate percentage range")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Divider().padding(.top, 8)
                }
                .padding(.horizontal)
                
                
                // MARK: - Descriptions With Colored Dots
                VStack(alignment: .leading, spacing: 30) {
                    infoSection(
                        color: .blue,
                        title: "Warm-up Heart Rate Range:",
                        text: "50%~60%: Warm-up rate range, used to cultivate physical fitness or to warm up before exercise. Type of exercise, such as brisk walking."
                    )
                    
                    infoSection(
                        color: .green,
                        title: "Fat burning Heart Rate Range:",
                        text: "60%~70%: The fat-burning heart rate range is used to improve basic physical fitness, increase the rate of fat release, and regulate the cardiovascular system. Type of exercise, such as jogging."
                    )
                    
                    infoSection(
                        color: .yellow,
                        title: "Aerobic Endurance Heart Rate Range:",
                        text: "70%~80%: Aerobic endurance heart rate range, used for endurance training, is beneficial to improve aerobic fitness, increase lung capacity, and control breathing rhythm. Type of exercise, such as easy running."
                    )
                    
                    infoSection(
                        color: .orange,
                        title: "Anaerobic Endurance Heart Rate Range",
                        text: "80%-90%:The anaerobic endurance heart rate range is used for speed improvement training, which is beneficial to improve physical fitness. It is necessary to properly control the exercise time in this zone. Type of exercise, such as tempo or interval training."
                    )
                    
                    infoSection(
                        color: .red,
                        title: "Limit",
                        text: "90%~100%: The limit heart rate range is used for explosive exercise. At this time, lactic acid accumulates rapidly and is prone to injury. It is necessary to strictly control the exercise time in this range. Type of exercise, such as extreme running.\nHeart rate is the frequency of the heart beating, expressed in the number of heart beats per minute, and it is usually 50 to 100 beats per minute for adults in the state of lung activity.\nThe heart provides blood circulation, oxygen and nutrients to the body, and heart rate can be regarded as an important indicator of cardiovascular health.\nHeart rate varies from person to person due to age, gender or other physiological factors. In general, the older you are, the faster your heart rate is, and women's heart rates are faster than boys of the same age. Heart rate during sleep is generally lower than when awake, and heart rate during exercise varies with exercise intensity.\nPlease note that this feature is not designed for medical use, please consult a healthcare professional if you have any questions or health concerns."
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Heart Rate")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    private func labelRow(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .frame(height: 44, alignment: .center)
    }
    
    private func valueRow(_ text: String, _ color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.85))
            .frame(width: 65, height: 44)
            .overlay(
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
            )
    }
    
    private func infoSection(color: Color, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text(text)
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}
