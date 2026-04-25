//
//  StartView.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
import SwiftData

struct StartView: View {
    @State private var session = SessionManager.shared
    
    var body: some View {
        NavigationStack {
            ShuffleView(filter: nil)
        }
        // CHANGE: Overlay LockView on top of everything when locked
        .overlay {
            if session.isLocked() {
                LockView()
                    .transition(.opacity)
            }
        }
        // CHANGE: Animate the lock appearing/disappearing
        .animation(.easeInOut, value: session.isLocked())
        .background(Color.theme)
    }
}

#Preview {
    NavigationStack{
        StartView()
            .modelContainer(Moment.preview)
    }
}
