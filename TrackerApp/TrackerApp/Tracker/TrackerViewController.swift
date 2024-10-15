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
    var visiableCategories: [TrackerCategory] = []
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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseId)
        collectionView.register(TrackerCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        return collectionView
    }()
    
    var currentDate: Date = Date()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setUpNavigationBar()
        setUpEmptyTrackersImage()
        setUpEmptyTrackersLabel()
        setUpCollectionView()
        
        let testCategory = TrackerCategory(header: "Домашний уют", trackers: trackers)
        categories.append(testCategory)
    }
    
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
        currentDate = selectedDate
        
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
        
        guard let emptyTrackersLabel else { return }
        emptyTrackersImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyTrackersImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        emptyTrackersImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyTrackersImage.bottomAnchor.constraint(equalTo: emptyTrackersLabel.topAnchor, constant: -40).isActive = true
    }
    
    private func setUpEmptyTrackersLabel() {
        let emptyTrackersLabel = UILabel()
        emptyTrackersLabel.text = "Что будем отслеживать?"
        emptyTrackersLabel.textColor = .ypBlack
        emptyTrackersLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        view.addSubview(emptyTrackersLabel)
        emptyTrackersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyTrackersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyTrackersLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    
}


//MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visiableCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath)
                as? TrackersCollectionViewCell else { return UICollectionViewCell()}
        
        
        cell.prepareForReuse()
        let tracker = visiableCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(tracker: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "header",
                                                                         for: indexPath) as? TrackerCVHeader else {
            return UICollectionReusableView()
        }
        
        
        view.setTitle(visiableCategories[indexPath.section].header)
        return view
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return visiableCategories.count
        }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDay
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 47)
    }
}

//MARK: - TrackersCellDelegate
extension TrackerViewController:TrackersCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            completedTrackers.append(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
