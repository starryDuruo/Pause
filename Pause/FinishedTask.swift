//
//  FinishedTask.swift
//  Pause
//
//  Created by Wang Sige on 4/17/26.
//

import Foundation
import SwiftData
import PencilKit

@Model
class FinishedTask {
    var timestamp: Date
    var taskTitle: String
    var drawingData: Data? // This is our drawing saved as bits
    var note: String
    
    init(taskTitle: String, drawingData: Data? = nil, note: String = "") {
        self.timestamp = Date()
        self.taskTitle = taskTitle
        self.drawingData = drawingData
        self.note = note
    }
}
