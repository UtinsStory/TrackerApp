//
//  TrackerCategory.swift
//  TrackerApp
//
//  Created by Гена Утин on 30.09.2024.
//

import Foundation

struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
    
    init(header: String, trackers: [Tracker]) {
        self.header = header
        self.trackers = trackers
    }
}
