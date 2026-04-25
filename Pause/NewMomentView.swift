//
//  NewMomentView.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct NewMomentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var prompt: String = ""
    @State private var selectedInteraction: Interaction = .write
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data? = nil
    
    var body: some View {
        List {
            TextField("Prompt", text: $prompt, axis: .vertical)
                .lineLimit(2...4)
            Picker("Interaction Type", selection: $selectedInteraction) {
                Text("Write").tag(Interaction.write)
                Text("Draw").tag(Interaction.draw)
                Text("None").tag(Interaction.act)
            }
            .pickerStyle(.menu)
           
            Section {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Label("Upload Image", systemImage: "photo.on.rectangle")
                        Spacer()
                        if selectedImageData != nil {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(8)
                }
            } header: { Text("Optional") }
        }
        .padding()
        .font(.title)
        .listStyle(.plain) // The requested style
        .navigationTitle("Add Template")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    save()
                }
                .disabled(prompt.isEmpty)
            }
        }
    }
    
    func save() {
        let newMoment = Moment(
            prompt: prompt,
            interaction: selectedInteraction,
            imageName: "", // No asset name for user uploads
            imageData: selectedImageData // Store the actual data here
        )
        modelContext.insert(newMoment)
        dismiss()
    }
}

#Preview {
    NavigationStack{
        NewMomentView()
    }
}
