//
//  LocalizationHelper.swift
//  TrackerApp
//
//  Created by Гена Утин on 15.11.2024.
//

import Foundation

public class LocalizationHelper {
    public static func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}


