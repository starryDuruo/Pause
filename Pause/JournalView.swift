//
//  JournalView.swift
//  Pause
//
//  Created by Wang Sige on 4/17/26.
//

import SwiftUI
import SwiftData
import PencilKit

struct JournalView: View {
    
    // 1. Fetch the saved data from SwiftData, sorted by date (newest first)
    @Query(sort: \FinishedTask.timestamp, order: .reverse) var savedTasks: [FinishedTask]
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
            List {
                if savedTasks.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Moments Yet", systemImage: "pencil.and.outline", description: Text("Finish a task to see your journey here."))
                    Spacer()
                } else {
                    // The Timeline Container
                    ForEach(savedTasks) { task in
                        TimelineRow(task: task, isLast: task.id == savedTasks.last?.id)
                        .listRowSeparator(.hidden) // Keeps your timeline looking clean
                        .listRowBackground(Color.theme) 
                        .listRowInsets(EdgeInsets()) // Removes default padding to keep line aligned
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    
                }
                
            }
            .listStyle(.plain)
            .padding()
            .scrollContentBackground(.hidden)
            .background(Color.theme)
            .navigationTitle("Your Journey")
        }
    }


struct TimelineRow: View {
    let task: FinishedTask
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // LEFT COLUMN: The Line and Node
            VStack(spacing: 0) {
                // The Node (Circle)
                Circle()
                    .fill(.accent)
                    .frame(width: 12, height: 12)
                    .background(Circle().stroke(.accent.opacity(0.3), lineWidth: 4))
                
                // The Vertical Line (only if not the last item)
                if !isLast {
                    Rectangle()
                        .fill(.accent.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.leading)
            
            // RIGHT COLUMN: The Content
            VStack(alignment: .leading, spacing: 10) {
                // Date Header
                Text(task.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                // Task Title
                Text(task.taskTitle)
                    .font(.headline)
                
                // Text response
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }
                
                // Drawing response
                if let drawingData = task.drawingData,
                   let drawing = try? PKDrawing(data: drawingData),
                   !drawing.strokes.isEmpty {                          // CHANGE: use strokes.isEmpty, not bounds
                    let bounds = drawing.bounds.insetBy(dx: -20, dy: -20)
                    let image = drawing.image(from: bounds, scale: 2)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .background(.theme)
                        .cornerRadius(12)
                        .preferredColorScheme(.light)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.bottom, 30) // Space between timeline events
        }
    }
}

#Preview {
    // 1. Create a configuration that lives only in RAM (not saved to disk)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FinishedTask.self, configurations: config)

    // 2. Create some "Fake" data to see in the timeline
    let mockDrawing = PKDrawing().dataRepresentation() // Empty but valid
    let task1 = FinishedTask(taskTitle: "Draw a Cloud", drawingData: mockDrawing)
    let task2 = FinishedTask(taskTitle: "Draw a Tree", drawingData: mockDrawing)

    // 3. Add the fake tasks to the container
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)

    return JournalView()
        .modelContainer(container) // 4. Inject the container into the preview
}
