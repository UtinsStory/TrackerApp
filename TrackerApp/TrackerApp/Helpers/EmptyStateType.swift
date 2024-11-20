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
            return LocalizationHelper.localizedString("noCategoryText")
        case .noTrackers:
            return LocalizationHelper.localizedString("emptyTrackersText")
        case .noResults:
            return LocalizationHelper.localizedString("nothingFound")
        case .noStats:
            return "Анализировать пока нечего"
        }
    }
}

