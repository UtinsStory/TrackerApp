//
//  TrackerViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var header: UILabel!
    @IBOutlet private var emptyTrackersImage: UIImageView!
    @IBOutlet private var emptyTrackersLabel: UILabel!
    @IBOutlet private var addTrackerButton: UIButton!
    @IBOutlet private var datePicker: UIDatePicker!
    
    // MARK: - Public Properties
    var trackers: [Tracker] = []
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    
    // MARK: - Private Properties
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsBookmarkButton = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let dateString = dateFormatter.string(from: Date())
        let date = dateFormatter.date(from: dateString)!
        datePicker.setDate(date, animated: true)
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
