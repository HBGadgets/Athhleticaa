//
//  CountdownScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 28/11/25.
//

import SwiftUI

struct CountdownScreen: View {
    @State private var count = 3
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0
    var onFinish: (() -> Void)? = nil
    @ObservedObject var ringManager: QCCentralManager
    @State private var goToSportsActivityScreen = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("\(count)")
                .font(.system(size: 180, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    startCountdown()
                }
        }
        .statusBar(hidden: true)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
        .navigationDestination(isPresented: $goToSportsActivityScreen) {
            SportActivityScreen(ringManager: ringManager)
        }
    }

    private func startCountdown() {
        animateNumber()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if count == 1 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onFinish?()
                    goToSportsActivityScreen = true
                }
            } else {
                count -= 1
                animateNumber()
            }
        }
    }

    private func animateNumber() {
        scale = 0.1
        opacity = 1

        withAnimation(.easeOut(duration: 0.6)) {
            scale = 1.2
            opacity = 0
        }
    }
}
