//
//  Tracker.swift
//  TrackerApp
//
//  Created by Гена Утин on 30.09.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
}
