//
//  DrawingView.swift
//  Pause
//
//  Created by Wang Sige on 4/17/26.
//

import SwiftUI
import SwiftData
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var selectedColor: Color
    var toolType: PKInkingTool.InkType
    var onDrawingChange: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        canvasView.overrideUserInterfaceStyle = .light
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // This updates the brush whenever the color or tool changes in your UI
        uiView.tool = PKInkingTool(toolType, color: UIColor(selectedColor))
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(onDrawingChange: onDrawingChange)
        }

        class Coordinator: NSObject, PKCanvasViewDelegate {
            var onDrawingChange: () -> Void
            init(onDrawingChange: @escaping () -> Void) {
                self.onDrawingChange = onDrawingChange
            }
            // This UIKit function fires whenever a stroke is made or undone
            func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
                onDrawingChange()
            }
        }
}

struct CloudTaskView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = .white
    @State private var tool: PKInkingTool.InkType = .watercolor
    @State private var canUndo = false
    
    @Environment(\.modelContext) var modelContext
    // We access the undo manager from the environment
    @Environment(\.undoManager) var undoManager

    var body: some View {
        VStack {
            // ... Your Task Text and DrawingView here ...
           
            DrawingView(canvasView: $canvasView,
                        selectedColor: selectedColor,
                        toolType: tool){
                canUndo = canvasView.undoManager?.canUndo ?? false
            }
                .frame(height: 400)
                .background(Color.blue.opacity(0.3))
                .cornerRadius(15)
                .padding()
            
            // Tool Switcher
            HStack(spacing: 20) {
                Text("Custom color for:")
                Button("Brush ") {
                    tool = .watercolor
                    selectedColor = .white
                }
                
                Button("Pen") {
                    tool = .pen
                    selectedColor = .gray
                }
                
                ColorPicker("Color", selection: $selectedColor)
                    .labelsHidden()
            }
            .padding()
            
            // Action Bar
            HStack{
                // UNDO BUTTON
                Button(action: {
                    undoManager?.undo()
                    canUndo = canvasView.undoManager?.canUndo ?? false
                }) {
                    Label("Undo", systemImage: "arrow.uturn.backward.circle")
                }
                .disabled(!canUndo)
                .buttonStyle(.glass)
                
                Spacer()
                // CLEAR BUTTON
                Button(action: {
                    clearCanvas()
                    canvasView.undoManager?.removeAllActions()
                    canUndo = false
                }) {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(!canUndo)
                .tint(.red)
                .buttonStyle(.glass)
                
                Spacer()
                
                Button {
                    saveDrawing()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
                .disabled(!canUndo)
                .tint(.green)
                .buttonStyle(.glassProminent)

            }
            .controlSize(.large)
            .padding(.horizontal)
            
            
        }
    }

    func clearCanvas() {
        // This is the cleanest way to clear in PencilKit
        canvasView.drawing = PKDrawing()
    }
    
    func saveDrawing() {
        // 1. Convert the PKDrawing to Data
        let drawingData = canvasView.drawing.dataRepresentation()
        
        // 2. Create a new FinishedTask object
        let newTask = FinishedTask(
            taskTitle: "Draw a Cloud",
            drawingData: drawingData
        )
        
        // 3. Save it to SwiftData
        modelContext.insert(newTask)
        
        // 4. (Optional) Clear the canvas for the next "Pause" session
        clearCanvas()
        
        print("Task saved to your Reality Journal!")
        
    }
}

#Preview {
    CloudTaskView()
}
