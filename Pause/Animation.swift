//
//  Animation.swift
//  Pause
//
//  Created by Wang Sige on 4/17/26.
//

import SwiftUI

struct ConfettiPiece: View {
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    let color: Color = [.red, .blue, .green, .yellow, .pink, .orange].randomElement()!
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    // Explode outward in random directions
                    xOffset = CGFloat.random(in: -200...200)
                    yOffset = CGFloat.random(in: -400...0) // Up and out
                    opacity = 0
                }
            }
    }
}

struct Confetti: View {
    // Internal state to trigger the animation once
    @State private var hasAppeared = false
    
    var body: some View {
        ZStack {
            if hasAppeared {
                ForEach(0..<50, id: \.self) { index in
                    ConfettiPiece()
                }
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }
}

struct ConfettiPreview: View {
    @State private var testID = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Every time testID changes, a "new" Confetti view is created
            // and its .onAppear fires automatically
            Confetti()
                .id(testID)
            
            VStack {
                Spacer()
                Button("Test Explosion") {
                    testID += 1
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}


#Preview {
    ConfettiPreview()
}
