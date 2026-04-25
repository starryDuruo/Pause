//
//  MomentListView.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
import SwiftData

struct FilteredMomentList: View {
    @Query var moments: [Moment]
    @Environment(\.modelContext) var modelContext
    let currentFilter: Interaction? // Store this for the shuffle button

    init(filter: Interaction?) {
        self.currentFilter = filter
        
        if let filterValue = filter {
            let targetRaw = filterValue.rawValue // Extract to local constant
            _moments = Query(filter: #Predicate<Moment> {
                $0.interactionRaw == targetRaw // Compare stored string to local string
            }, sort: \Moment.prompt)
        } else {
            _moments = Query(sort: \Moment.prompt)
        }
    }

    var body: some View {
        List {
            // SHUFFLE BUTTON: Only shows if we are looking at a specific group
            if let filter = currentFilter {
                NavigationLink(destination: ShuffleView(filter: filter)
                    .id(filter.rawValue) // CHANGE: Force a fresh view instance)
                ){
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle \(filter.rawValue) moments")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.accent)
                }
                
            }

            ForEach(moments) { moment in
                // Individual Moment Link
                NavigationLink(destination:
                    MomentView(
                        moment: moment,
                        shouldDismissOnAction: true,
                        onSkip: { },
                        onSave: { text, drawing in
                            let promptToSave = moment.prompt
                            let typeToSave = moment.interaction
                            
                            SessionManager.shared.saveResponse(
                                prompt: promptToSave,
                                interaction: typeToSave,
                                text: text,
                                drawing: drawing,
                                context: modelContext
                            )
                        }
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text(moment.prompt)
                            .font(.headline)
                        Text(moment.interaction.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteMoments)
        }
        .background(.theme)
        .listStyle(.plain)
    }

    private func deleteMoments(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moments[index])
        }
    }
}

struct MomentListView: View {
    // nil means "All"
    @State private var filterSelection: Interaction? = nil
    @State private var showingAddSheet = false

    var body: some View {
        // No NavigationStack here because it's usually inside ContentView's stack
        VStack {
            FilteredMomentList(filter: filterSelection)
            // CHANGE: Adding .id forces the view to refresh when the filter changes
            // This ensures the Shuffle button appears/disappears immediately.
                .id(filterSelection?.rawValue ?? "all")
                .navigationTitle("Templates")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showingAddSheet.toggle() } label: {
                            Image(systemName: "plus")
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Picker("Filter", selection: $filterSelection) {
                            Text("All").tag(nil as Interaction?)
                            Text("Write").tag(Interaction.write as Interaction?)
                            Text("Draw").tag(Interaction.draw as Interaction?)
                            Text("Action").tag(Interaction.act as Interaction?)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    NavigationStack {
                        NewMomentView()
                    }
                }
        }
        
    }
}

#Preview {
    NavigationStack{
        MomentListView()
            .modelContainer(Moment.preview)
    }
}
