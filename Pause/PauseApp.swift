//
//  PauseApp.swift
//  Pause
//
//  Created by Wang Sige on 4/16/26.
//

import SwiftUI
import SwiftData

@main
struct PauseApp: App {
    var container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: [Moment.self, FinishedTask.self])
        }
        
    }
    
    init() {
        do {
            // 3. Initialize the real storage (not in-memory)
            container = try ModelContainer(for: Moment.self, FinishedTask.self)
            
            // 4. Check if we need to seed data
            checkAndSeedData()
        } catch {
            fatalError("Failed to configure SwiftData Container")
        }
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    @MainActor
    private func checkAndSeedData() {
        let context = container.mainContext
        
        // 5. Fetch to see if moments already exist
        let descriptor = FetchDescriptor<Moment>()
        if let existingCount = try? context.fetchCount(descriptor), existingCount == 0 {
            // 6. If 0, insert the defaults
            for moment in Moment.defaultMoments {
                context.insert(moment)
            }
            // Save explicitly
            try? context.save()
            print("Database seeded with default moments!")
        }
    }
}
