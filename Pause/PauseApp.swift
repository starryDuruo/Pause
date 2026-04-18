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
    var body: some Scene {
        WindowGroup {
            CloudTaskView()
        }
        .modelContainer(for: FinishedTask.self)
    }
}
