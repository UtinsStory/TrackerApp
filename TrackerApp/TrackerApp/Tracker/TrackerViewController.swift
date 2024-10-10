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
    var trackers: [Tracker] = []
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    
    // MARK: - Private Properties
    private var searchBar: UISearchBar!
    private var header: UILabel!
    private var emptyTrackersImage: UIImageView?
    private var emptyTrackersLabel: UILabel?
    private var addTrackerButton: UIButton {
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "plus"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        return addTrackerButton
    }
    private var datePicker: UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        return datePicker
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let testCategory: TrackerCategory = .init(header: "Лекарства", trackers: [])
    
    var currentDate: Date = Date()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setUpNavigationBar()
        setUpEmptyTrackersImage()
        setUpEmptyTrackersLabel()
    
//        let category = TrackerCategory(header: "Лекарства", trackers: <#T##[Tracker]#>)
        
        collectionView.dataSource = self
//        collectionView.delegate = self
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    @objc
    func addTrackerButtonTapped() {
        let addTrackerVC = AddTrackerViewController()
        addTrackerVC.trackerVC = self
        addTrackerVC.modalPresentationStyle = .pageSheet
        present(addTrackerVC, animated: true)
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        var currentDate = selectedDate
        
    }
    
    func addTracker(tracker: Tracker) {
        trackers.append(tracker)
        categories = categories.map { category in
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            return TrackerCategory(header: category.header, trackers: updatedTrackers)}
    }
    
    func reload() {
        collectionView.reloadData()
    }
    // MARK: - Private Methods
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Трекеры"
        if let navigationBar = navigationController?.navigationBar {
            let leftButton = UIBarButtonItem(customView: addTrackerButton)
            navigationBar.topItem?.setLeftBarButton(leftButton, animated: false)
            
            let rightButton = UIBarButtonItem(customView: datePicker)
            navigationBar.topItem?.setRightBarButton(rightButton, animated: false)
            
            navigationBar.topItem?.searchController = UISearchController()
        }
    }
    
    private func setUpEmptyTrackersImage() {
        let emptyTrackersImage = UIImageView(image: UIImage(named: "empty"))
        
        view.addSubview(emptyTrackersImage)
        emptyTrackersImage.translatesAutoresizingMaskIntoConstraints = false
        
        emptyTrackersImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyTrackersImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        emptyTrackersImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyTrackersImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                constant: 220).isActive = true
    }
    
    private func setUpEmptyTrackersLabel() {
        let emptyTrackersLabel = UILabel()
        emptyTrackersLabel.text = "Что будем отслеживать?"
        emptyTrackersLabel.textColor = .ypBlack
        emptyTrackersLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        view.addSubview(emptyTrackersLabel)
        emptyTrackersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let emptyTrackersImage else { return }
        
        emptyTrackersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersImage.bottomAnchor,
                                                constant: 8).isActive = true
        
    }
    
}

//MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                as? TrackersCollectionViewCell else { return UICollectionViewCell()}
        
        return cell
        
    }
}
