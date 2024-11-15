//
//  CategoryCreationViewModel.swift
//  TrackerApp
//
//  Created by Гена Утин on 14.11.2024.
//

import Foundation

final class CategoryCreationViewModel {
    
    var onCategoryCreation: ((String) -> Void)?
    var onCreationButtonStateUpdated: ((Bool) -> Void)?
    
    private let categoryStore = CoreDataMain.shared.trackerCategoryStore
    
    func addCategory(name: String) {
        categoryStore.createCategory(header: name)
        onCategoryCreation?(name)
    }

    func validateCategoryName(_ name: String?) {
        let isNameEntered = !(name?.isEmpty ?? true)
        onCreationButtonStateUpdated?(isNameEntered)
    }
    
}
