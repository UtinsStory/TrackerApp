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
    let color: String
    let emoji: String
    let schedule: [WeekDay]?
    let backupCategory: String?
    
    init(id: UUID, title: String, color: String, emoji: String, schedule: [WeekDay]?, backupCategory: String?) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.backupCategory = backupCategory
    }

    init(trackerCoreData: TrackerCoreData) {
        self.id = trackerCoreData.id ?? UUID()
        self.title = trackerCoreData.title ?? ""
        self.color = trackerCoreData.color ?? ""
        self.emoji = trackerCoreData.emoji ?? ""
        self.schedule = Tracker.deserializeSchedule(from: trackerCoreData.schedule ?? "")
        self.backupCategory = trackerCoreData.backupCategory ?? ""
    }

    var isIrregularEvent: Bool {
        return schedule?.isEmpty ?? true
    }

    func serializeSchedule() -> String? {
        guard let schedule = schedule else { return nil }
        let intArray = schedule.map { String($0.rawValue) }
        return intArray.joined(separator: ",")
    }

    static func deserializeSchedule(from string: String?) -> [WeekDay]? {
        guard let string = string else { return nil }
        let intArray = string.split(separator: ",").compactMap { Int($0) }
        return intArray.compactMap { WeekDay(rawValue: $0) }
    }
}
