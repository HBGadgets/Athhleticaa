//
//  ECGHRVInfoCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/03/26.
//

import SwiftUI

struct ECGHRVInfoCard: View {
    @Environment(\.colorScheme) var colorScheme
    var vpECGTestDataModel: VPECGTestDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Header
            HStack(spacing: 10) {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 20))
                
                Text("HRV")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.red)
            }
            
            // Rows
            VStack(spacing: 24) {
                hrvRow(
                    title: "HRV",
                    range: "0 ~ 210 ms",
                    value: "26",
                    showWarning: false
                )
                
                hrvRow(
                    title: "SDNN",
                    range: "102 ~ 180 ms",
                    value: "91",
                    showWarning: true
                )
                
                hrvRow(
                    title: "RMSSD",
                    range: "15 ~ 39 ms",
                    value: "124",
                    showWarning: true
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(colorScheme == .light ? .white : Color(.systemGray2))
                )
        )
        .padding()
    }
    
    @ViewBuilder
    func hrvRow(
        title: String,
        range: String,
        value: String,
        showWarning: Bool
    ) -> some View {
        
        HStack {
            
            // Left side (labels)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                
                Text(range)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Right side (value + warning)
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                
                if showWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 15))
                }
            }
        }
    }
}
