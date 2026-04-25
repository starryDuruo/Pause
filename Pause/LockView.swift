//
//  LockView.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
internal import Combine

struct LockView: View {
    @State private var timeRemaining:Int = Int(SessionManager.shared.lockInterval)
    @Environment(\.dismiss) private var dismiss
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Time to Pause")
                .font(.largeTitle).bold()
            
            Text("Put down your phone. Look around you.")
                .multilineTextAlignment(.center)
            
            Text("\(timeRemaining)s")
                .font(.system(size: 60, weight: .thin, design: .monospaced))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // Disable back button
        .onReceive(timer) { _ in
            if let endTime = SessionManager.shared.lockEndTime {
                let diff = Int(endTime.timeIntervalSince(Date()))
                if diff <= 0 {
                    SessionManager.shared.lockEndTime = nil // Unlock
                    dismiss()
                } else {
                    timeRemaining = diff
                }
            } else {dismiss()}
        }
    }
}

#Preview {
    LockView()
}
