//
//  SessionManager.swift
//  Pause
//
//  Created by Wang Sige on 4/20/26.
//

import SwiftUI
import SwiftData
import PencilKit

@Observable
class SessionManager {
    static let shared = SessionManager()
    let lockInterval = 10.0
    let lockThreshold = 3
    
    // Persistent across app restarts
    var taskCount: Int {
        get { UserDefaults.standard.integer(forKey: "taskCount") }
        set { UserDefaults.standard.set(newValue, forKey: "taskCount") }
    }
    
    // Track when the lock ends (persists if app closes)
    var lockEndTime: Date? {
        get {
            let intervals = UserDefaults.standard.double(forKey: "lockEndTime")
            return intervals == 0 ? nil : Date(timeIntervalSince1970: intervals)
        }
        set { UserDefaults.standard.set(newValue?.timeIntervalSince1970 ?? 0, forKey: "lockEndTime") }
    }

    @MainActor
    func saveResponse(prompt: String, interaction: Interaction, text: String, drawing: PKDrawing, context: ModelContext) {
        let newTask = FinishedTask(taskTitle: prompt)
        
        if interaction == .draw {
            newTask.drawingData = drawing.dataRepresentation()
        } else if interaction == .write {
            newTask.note = text
        }
        
        context.insert(newTask)
        
        taskCount += 1
        if taskCount >= lockThreshold {
            startLock()
        }
    }
    
    func startLock() {
        taskCount = 0 // Reset counter
        lockEndTime = Date().addingTimeInterval(lockInterval) // 30 seconds from now
    }
    
    func isLocked() -> Bool {
        guard let end = lockEndTime else { return false }
        if Date() >= end {
            lockEndTime = nil // Timer finished
            return false
        }
        return true
    }
}
