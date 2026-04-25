//
//  DrawingView.swift
//  Pause
//
//  Created by Wang Sige on 4/17/26.
//

import SwiftUI
import SwiftData
import PencilKit

struct DrawingPadView: UIViewRepresentable {
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

struct DrawingView: View {
    @Binding var drawing: PKDrawing
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = .white
    @State private var tool: PKInkingTool.InkType = .watercolor
    @State private var canUndo = false
    
    @Environment(\.modelContext) var modelContext
    // We access the undo manager from the environment
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        VStack {
            
            DrawingPadView(canvasView: $canvasView,
                           selectedColor: selectedColor,
                           toolType: tool) {
                drawing = canvasView.drawing
                canUndo = canvasView.undoManager?.canUndo ?? false
            }

                        .frame(height: 400)
                        .cornerRadius(15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 0.2)
                        }                        
            
            // Tool Switcher
            HStack(spacing: 20) {
                Text("Custom color for:")
                Button("", systemImage: "paintbrush.pointed.fill") {
                    tool = .watercolor
                    selectedColor = .white
                }
                
                Button("", systemImage: "pencil.tip") {
                    tool = .pen
                    selectedColor = .gray
                }
                
                ColorPicker("Color", selection: $selectedColor)
                    .labelsHidden()
            }
            .padding()
            
            // Action Bar
            HStack{
                Spacer()
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
                
            }
            .controlSize(.large)
            .padding(.horizontal)
            
            
        }
        .onChange(of: drawing) { _, newDrawing in
            canvasView.drawing = newDrawing  // sync the actual PKCanvasView
        }
    }
    
    
    func clearCanvas() {
        // This is the cleanest way to clear in PencilKit
        canvasView.drawing = PKDrawing()
    }
}

#Preview {
    DrawingView(drawing: .constant(PKDrawing()))
        .background(.theme)
}
