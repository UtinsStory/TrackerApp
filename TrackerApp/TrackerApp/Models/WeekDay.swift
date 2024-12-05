//
//  WeekDay.swift
//  TrackerApp
//
//  Created by Гена Утин on 30.09.2024.
//
import Foundation

private let calendar = Calendar(identifier: .gregorian)

enum WeekDay: Int, CaseIterable {
    
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    static func from(date: Date) -> WeekDay? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.weekday], from: date)
        guard let dayNum = components.weekday else {
            print("Не удалось определить день недели")
            return nil
        }
        return WeekDay(rawValue: dayNum == 1 ? 7 : dayNum - 1)
    }
    
    func asText() -> String {
        switch self {
        case .sunday:
            return LocalizationHelper.localizedString("sunday")
        case .monday:
            return LocalizationHelper.localizedString("monday")
        case .tuesday:
            return LocalizationHelper.localizedString("tuesday")
        case .wednesday:
            return LocalizationHelper.localizedString("wednesday")
        case .thursday:
            return LocalizationHelper.localizedString("thursday")
        case .friday:
            return LocalizationHelper.localizedString("friday")
        case .saturday:
            return LocalizationHelper.localizedString("saturday")
        }
    }
    
    func asShortText() -> String {
        switch self {
        case .sunday:
            return LocalizationHelper.localizedString("sundayShort")
        case .monday:
            return LocalizationHelper.localizedString("mondayShort")
        case .tuesday:
            return LocalizationHelper.localizedString("tuesdayShort")
        case .wednesday:
            return LocalizationHelper.localizedString("wednesdayShort")
        case .thursday:
            return LocalizationHelper.localizedString("thursdayShort")
        case .friday:
            return LocalizationHelper.localizedString("fridayShort")
        case .saturday:
            return LocalizationHelper.localizedString("saturdayShort")
        }
    }
}

extension Array where Element == WeekDay {
    var displayText: String {
        if isEverydaySelected(self) {
            return LocalizationHelper.localizedString("everyday")
        } else if isWeekdaysSelected(self) {
            return LocalizationHelper.localizedString("weekdays")
        } else if isWeekendSelected(self) {
            return LocalizationHelper.localizedString("weekends")
        } else {
            return map { $0.asShortText() }.joined(separator: ", ")
        }
    }
    
    private func isEverydaySelected(_ days: [WeekDay]) -> Bool {
        return Set(days) == Set(WeekDay.allCases)
    }
    
    private func isWeekdaysSelected(_ days: [WeekDay]) -> Bool {
        let weekdays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        return Set(days) == weekdays
    }
    
    private func isWeekendSelected(_ days: [WeekDay]) -> Bool {
        Set(days) == [.saturday, .sunday]
    }
}
