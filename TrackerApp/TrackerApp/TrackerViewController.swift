//
//  TrackerViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - IB Outlets

    // MARK: - Public Properties

    // MARK: - Private Properties
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var header: UILabel!
    @IBOutlet private var emptyTrackersImage: UIImageView!
    @IBOutlet private var emptyTrackersLabel: UILabel!
    @IBOutlet private var addTrackerButton: UIButton!
    // MARK: - Initializers

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsBookmarkButton = false
    }

    // MARK: - IB Actions
    @IBAction private func addTrackerButtonTapped() {
        let createTrackerVC = TrackersCreationViewController()
        createTrackerVC.trackerVC = self
        present(createTrackerVC, animated: true)
    }
    // MARK: - Public Methods

    // MARK: - Private Methods
    
    

}
