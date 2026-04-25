//
//  ContentView.swift
//  Pause
//
//  Created by Wang Sige on 4/16/26.
//

import SwiftUI
import SwiftData
import PencilKit

struct ShuffleView: View {
    @Query var allMoments: [Moment]
    @State private var momentList: [Moment] = []
    @State private var currentMoment: Moment?
    var filter: Interaction? = nil // nil = Home, otherwise = Filtered
    @Environment(\.modelContext) var modelContext
    var body: some View {
        ZStack {
            if let moment = currentMoment {
                // Pass the current moment and two closures (onSkip and onSave)
                MomentView(
                    moment: moment,
                    onSkip: { next() },
                    onSave: { text, drawing in
                        save(text: text, drawing: drawing)
                    }
                )
                .id(moment.id)
            } else {
                // Fallback if no moments exist in SwiftData
                ContentUnavailableView("No Moments", systemImage: "sparkles")
            }
        }
        .background(Color.theme)
        .fullScreenCover(isPresented: Binding(
            get: { SessionManager.shared.isLocked() },
            set: { _ in }
        )) {
            LockView()
        }
        .onAppear { setupDeck() }
        .onChange(of: filter) { setupDeck() }
        .toolbar {
            // ONLY show these if we are at the "Root" (filter is nil)
            if filter == nil {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: MomentListView()) {
                        Image(systemName: "book.pages")
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: JournalView()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    func setupDeck() {
        // CHANGE: Use a guard to ensure we have data, otherwise wait
        guard !allMoments.isEmpty else { return }

        // CHANGE: Perform filtering on a local constant to avoid threading issues
        let currentFilter = self.filter
        
        let filtered = allMoments.filter { moment in
            if let targetFilter = currentFilter {
                // Use the raw value for comparison to be safe
                return moment.interactionRaw == targetFilter.rawValue
            }
            return true // No filter, return everything
        }
        
        // CHANGE: Only update the state if we actually found moments
        if !filtered.isEmpty {
            self.momentList = filtered.shuffled()
            next()
        }
    }
    func next() {
        guard !momentList.isEmpty else {
            setupDeck()
            return
        }
        withAnimation(.default) {
            currentMoment = momentList.removeFirst()
        }
    }
    
    // Logic: Receives data from MomentView, saves it, then triggers next()
    func save(text: String, drawing: PKDrawing) {
        guard let moment = currentMoment else { return }
        SessionManager.shared.saveResponse(
            prompt: moment.prompt,
            interaction: moment.interaction,
            text: text,
            drawing: drawing,
            context: modelContext)
        next()
    }
}


#Preview {
    NavigationStack{
        ShuffleView()
            .modelContainer(Moment.preview)
    }
}
