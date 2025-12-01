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
                Text("""
                    Total steps
                    Daily steps are a measure of your daily physical activity. The optimal daily steps depend on your age, body type, fitness level, and readiness to perform.

                    You should ensure that you can reach a standard of more than 8,000 steps per day. If you exercise, you can reduce the number of steps appropriately. The more steps are not necessarily better, because too many steps may cause potential knee and ankle strain, so it is recommended that the number of steps should be controlled between 8,000 and 15,000.

                    Total calories
                    Total calories are your total daily energy expenditure, including all the calories you burn during the day. Whether you are active or resting, tracking your total calories and comparing it with your data history can help you adjust your calorie intake and maintain a healthy weight.

                    Although exercise will increase your daily calorie consumption, most of your total consumption comes from the calories consumed while resting, also known as your basal metabolic rate (BMR). The device will start calculating your total burn in the early morning and record your estimated BMR.

                    This software and the associated smart ring device are not medical devices; the data and recommendations provided are for reference only and must not be used as basis for clinical diagnosis or treatment. Users should consult a physician before making any medical decisions.
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
