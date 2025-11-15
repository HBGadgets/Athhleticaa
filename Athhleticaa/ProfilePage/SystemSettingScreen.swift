//
//  SystemSettingScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 14/11/25.
//

import SwiftUI

struct SystemSettingScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @State private var showResetAlert = false
    @State private var showRestartAlert = false
    @State private var showErrorOccuredAlert = false
    @State private var showResetSuccessAlert = false
    @State private var showRestartSuccessAlert = false
    
    func resetRingToFactory() {
        QCSDKCmdCreator.resetBand(toFacotrySuccess: {
            showResetSuccessAlert = true
        }, fail: {
            showErrorOccuredAlert = true
        })
    }
    
    func restartRing() {
        QCSDKCmdCreator.resetBandHardlySuccess({
            showResetSuccessAlert = true
        }, fail: {
            showErrorOccuredAlert = true
        })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingItem(
                    title: "Restart",
                )
                .onTapGesture {
                    showRestartAlert = true
                }
                
                SettingItem(
                    title: "Reset",
                )
                .onTapGesture {
                    showResetAlert = true
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        // restart alert
        .alert("Confirmation", isPresented: $showRestartAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Okay") {
                restartRing()
            }
        } message: {
            Text("Ring will be restarted")
        }
        
        // reset alert
        .alert("Confirmation", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Okay") {
                resetRingToFactory()
            }
        } message: {
            Text("It will delete your data in the device, including:\n\n- Steps, calories, distance data\n- Sleep monitoring data")
        }
        
        // error alert
        .alert("Error", isPresented: $showErrorOccuredAlert) {
        } message: {
            Text("An error occured, please try again")
        }
        
        // reset done alert
        .alert("Success", isPresented: $showErrorOccuredAlert) {
        } message: {
            Text("Ring resetted successfully")
        }
        
        // restart done alert
        .alert("Success", isPresented: $showErrorOccuredAlert) {
        } message: {
            Text("Ring restarted successfully")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("System setting").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingItem: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)
    }
}
