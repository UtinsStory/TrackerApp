//
//  Date+Extension.swift
//  TrackerApp
//
//  Created by Гена Утин on 26.11.2024.
//

import Foundation

extension Date {
    public var removeTimeStamp : Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return nil
        }
        return date
    }
}
