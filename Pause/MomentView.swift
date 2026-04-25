//
//  MomentView.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
import PencilKit

struct MomentView: View {
    var moment: Moment
    var shouldDismissOnAction: Bool = false  // ShuffleView passes false (default)
    // Internal state for the current session
    @State private var text: String = ""
    @State private var drawing: PKDrawing = PKDrawing()
    @State private var showCelebration = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Callbacks to notify the parent
    var onSkip: () -> Void
    var onSave: (String, PKDrawing) -> Void // Passes back the data to be saved
    
    private var isResponseEmpty: Bool {
        switch moment.interaction {
        case .write: return text.trimmingCharacters(in: .whitespaces).isEmpty
        case .draw:  return drawing.strokes.isEmpty
        case .act:   return false  // action moments have nothing to fill in, always enabled
        }
    }
    
    var body: some View {
        ZStack {
            // Background managed here to ensure it ignores safe area
            Color.theme.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text(moment.prompt)
                    .font(.largeTitle)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal)
                
                if !moment.imageName.isEmpty {
                    Image(moment.imageName)
                        .resizable()
                        .scaledToFit()
                }
                                
                switch moment.interaction {
                case .draw:
                    DrawingView(drawing: $drawing)
                case .write:
                    TextField("Your moment", text: $text, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                case .act:
                    Spacer()
                }
                
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button("Skip") {
                        onSkip()
                        if shouldDismissOnAction { dismiss() }
                    }
                    .buttonStyle(.glass)
                    
                    Spacer()
                    
                    Button("Finished", systemImage: "checkmark.circle.fill") {
                        triggerSave()
                    }
                    .tint(.green)
                    .buttonStyle(.glassProminent)
                    .disabled(isResponseEmpty)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .padding()
            
            if showCelebration {
                Confetti()
                    .transition(.opacity)
            }
        }
        .background(Color.theme.ignoresSafeArea())
        .onChange (of: moment.id) {
            text = ""
            drawing = PKDrawing()
        }
    }
    
    private func triggerSave() {
        withAnimation {
            showCelebration = true
        }
        
        // Wait 1.5 seconds for confetti, then tell parent to save/move on
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onSave(text, drawing)
            showCelebration = false
            if shouldDismissOnAction { dismiss() }  // Only fires from list nav
        }
    }
}

#Preview {
    NavigationStack{
        MomentView(moment: Moment(prompt:"Keep Coding!", interaction: .act)) {
            print("Skip pressed in preview")
        } onSave: { _,_ in
            print("Save pressed in preview")
        }

    }
}
