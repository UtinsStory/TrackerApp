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
            return "Воскресенье"
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        }
    }
    
    func asShortText() -> String {
        switch self {
        case .sunday:
            return "Вс"
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        }
    }
}
