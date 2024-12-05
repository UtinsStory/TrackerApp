//
//  TrackerAppTests.swift
//  TrackerAppTests
//
//  Created by Гена Утин on 27.09.2024.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerAppTests: XCTestCase {
    
    func testTrackersViewControllerLightMode() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkMode() {
        let vc = TrackerViewController()
        vc.loadViewIfNeeded()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
}

