//
//  HRVScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUICore

import SwiftUI
import Charts

struct HRVScreenView: View {
    @ObservedObject var ringManager: QCCentralManager
    @State private var isMeasuring = false
    @State private var currentHeartRate: Int? = nil
    @State private var animateHeart = false
    
    var body: some View {
        VStack(spacing: 20) {
            
        }
    }
}
