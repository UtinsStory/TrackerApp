//
//  EmptyStateType.swift
//  TrackerApp
//
//  Created by Гена Утин on 14.11.2024.
//

import UIKit

enum EmptyStateType {
    case noCategories
    case noTrackers
    case noResults
    case noStats

    var image: UIImage? {
        switch self {
        case .noCategories:
            return UIImage(named: "empty")
        case .noTrackers:
            return UIImage(named: "empty")
        case .noResults:
            return UIImage(named: "empty_search")
        case .noStats:
            return UIImage(named: "empty_search2")
        }
    }

    var text: String {
        switch self {
        case .noCategories:
            return "Привычки и события можно\nобъединить по смыслу"
        case .noTrackers:
            return "Что будем отслеживать?"
        case .noResults:
            return "Ничего не найдено"
        case .noStats:
            return "Анализировать пока нечего"
        }
    }
}

