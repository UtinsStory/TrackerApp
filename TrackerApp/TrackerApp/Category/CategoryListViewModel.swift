//
//  CategoryListViewModel.swift
//  TrackerApp
//
//  Created by Гена Утин on 14.11.2024.
//

import Foundation

final class CategoryListViewModel {
    // MARK: - Properties

    var categories: [TrackerCategory] = [] {
        didSet {
            updateViewState()
        }
    }

    var selectedCategory: TrackerCategory?
    var selectedIndex: IndexPath?

    // MARK: - Closures

    var onCategorySelected: ((String) -> Void)?
    var onViewStateUpdated: ((ViewState) -> Void)?

    private(set) var viewState: ViewState = .empty {
        didSet {
            onViewStateUpdated?(viewState)
        }
    }
    
    private let categoryStore = CoreDataMain.shared.trackerCategoryStore

    // MARK: - Initialization

    init() {
        loadCategories()
    }

    // MARK: - Methods

    func loadCategories() {
        categories = categoryStore.fetchCategories()
        updateViewState()
    }

    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectedIndex = IndexPath(row: index, section: 0)
        onCategorySelected?(categories[index].header)
    }

    private func updateViewState() {
        let state: ViewState = categories.isEmpty ? .empty : .populated
        viewState = state
    }
}
