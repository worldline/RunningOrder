//
//  Storage.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 13/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

class Storage {
    static var sprints: [Sprint] = Sprint.Previews.sprints
    static var stories: [Sprint.ID:[Story]] = [Sprint.Previews.sprints[0].id:Story.Previews.stories]
    static var informations: [Story.ID:StoryInformation] = {
        var informations: [Story.ID:StoryInformation] = [:]
        for story in Story.Previews.stories {
            informations[story.id] = StoryInformation(storyId: story.id)
        }

        return informations
    }()
}
