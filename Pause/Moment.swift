//
//  Moment.swift
//  Pause
//
//  Created by Wang Sige on 4/19/26.
//

import Foundation
import SwiftData

enum Interaction: String, Codable, CaseIterable, Identifiable {
    case draw, write, act
    var id: String { self.rawValue } 
}

@Model
class Moment {
    var prompt: String
    var interactionRaw: String = ""//This must be a stored property for the Predicate to find it, not computed properties.
    var imageName: String // For your built-in assets
    var imageData: Data?  // For user-uploaded photos
    
    var interaction: Interaction {
        get { Interaction(rawValue: interactionRaw) ?? .act }
        set { interactionRaw = newValue.rawValue }
    }
    
    init(prompt: String, interaction: Interaction, imageName: String = "", imageData: Data? = nil) {
        self.prompt = prompt
        self.imageName = imageName
        self.imageData = imageData
        self.interactionRaw = interaction.rawValue
    }
}

extension Moment {
    static var defaultMoments: [Moment] {
        [
            //DRAWING
            Moment(prompt: "Look up and observe the sky for a while. Draw your favorite cloud:", interaction: .draw),
            Moment(prompt: "Look at the nearest plant or tree. Draw the unique shape of one of its leaves:", interaction: .draw),
            Moment(prompt: "Find an object nearby that is your favorite color. Draw its silhouette:", interaction: .draw),
            Moment(prompt: "What are you wearing today? Sketch your favorite part of your outfit:", interaction: .draw),
            Moment(prompt: "Look at the pattern on the floor or a rug nearby. Recreate a small section of it here:", interaction: .draw),
            Moment(prompt: "Observe the shoes you are wearing. Draw them from a bird's-eye view:", interaction: .draw),
            Moment(prompt: "Find a window. Draw the very first thing you see on the other side of the glass:", interaction: .draw),
            Moment(prompt: "Look at your morning coffee or tea mug. Draw the steam rising from it:", interaction: .draw),
            Moment(prompt: "Pick up a small object within reach (a key, a pen, a coin). Draw it in great detail:", interaction: .draw),

            //\WRITING
            Moment(prompt: "What is the last meal you ate?", interaction: .write),
            Moment(prompt: "Close your eyes and listen. Write down three distinct sounds you can hear right now:", interaction: .write),
            Moment(prompt: "Think about the last person you spoke to. What was the very first thing they said to you?", interaction: .write),
            Moment(prompt: "What is a physical sensation you are feeling right now? (e.g., warmth, a breeze, a tight muscle):", interaction: .write),
            Moment(prompt: "Write down one thing that happened in the last 24 hours that made you feel capable:", interaction: .write),
            Moment(prompt: "Look at the light in the room. Where is it coming from and what kind of shadows is it casting?", interaction: .write),
            Moment(prompt: "What is the most beautiful thing you've seen since you woke up today?", interaction: .write),
            Moment(prompt: "Identify a scent in your current environment. What does it remind you of?", interaction: .write),
            Moment(prompt: "Write a one-sentence thank you note to your body for something it did for you today:", interaction: .write),
            Moment(prompt: "What is a 'small win' you had this morning, no matter how tiny?", interaction: .write),

            //ACTION
            Moment(prompt: "Let's fold an origami crane", interaction: .act, imageName: "origami_crane"), // [IMAGE NEEDED]
            Moment(prompt: "Let's fold an origami heart", interaction: .act, imageName: "origami_heart"), // [IMAGE NEEDED]
            Moment(prompt: "Let's fold an origami frog", interaction: .act, imageName: "origami_frog"), // [IMAGE NEEDED]
            Moment(prompt: "Tell a friend that you really like them. Send the text now!", interaction: .act),
            Moment(prompt: "Box Breathing: Inhale for 4s, Hold for 4s, Exhale for 4s, Hold for 4s. Do this 3 times.", interaction: .act),
            Moment(prompt: "Stand up and reach for the ceiling. Stretch as high as you can, then let your arms drop.", interaction: .act),
            Moment(prompt: "Gently press your feet into the floor. Feel the ground supporting you for 30 seconds.", interaction: .act),
            Moment(prompt: "Drink a full glass of water. Notice the temperature as you swallow.", interaction: .act),
            Moment(prompt: "Find something textured nearby (fabric, wood, stone). Run your fingers over it 10 times.", interaction: .act),
            Moment(prompt: "Lower your shoulders away from your ears and take one deep, audible sigh.", interaction: .act)
        ]
    }
}

extension Moment  {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: Moment.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        for moment in defaultMoments {
            container.mainContext.insert(moment)
        }

        return container
    }
}
