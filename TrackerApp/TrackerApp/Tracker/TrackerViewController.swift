//
//  TrackerViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDelegate {
    
    private let placeholderNoFilterResults = PlaceholderNoFilterResultsView()
    
    private var collectionView: UICollectionView!
    private var currentDate = Date()
    
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs: Set<UUID> = []
    
    private var completedIrregularEvents: Set<UUID> = []
    private var trackerCreationDates: [UUID: Date] = [:]
    
    private var parameters: GeometricParameters
    private var isSearching = false
    
    private var selectedFilter: TrackerFilterHelper = .all
    private var filterButton: UIButton!
    
    private lazy var emptyState: PlaceholderView = {
        let placeholder = PlaceholderView()
        return placeholder
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypGray
        label.font = UIFont(name: "SF Pro", size: 17)
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.layer.zPosition = 1000
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let pickerDate = UIDatePicker()
        pickerDate.preferredDatePickerStyle = .compact
        pickerDate.datePickerMode = .date
        pickerDate.locale = Locale(identifier: "ru_RU")
        pickerDate.calendar = Calendar(identifier: .gregorian)
        pickerDate.calendar.firstWeekday = 2
        pickerDate.translatesAutoresizingMaskIntoConstraints = false
        pickerDate.clipsToBounds = true
        pickerDate.layer.cornerRadius = 8
        pickerDate.tintColor = .ypBlue
        pickerDate.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return pickerDate
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = LocalizationHelper.localizedString("search")
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.searchTextField.textColor = .ypBlack
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: LocalizationHelper.localizedString("search"),
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray])
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            if let leftView = textFieldInsideSearchBar.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ? .white : .gray
                }
            }
        }
        
        return searchBar
    }()
    
    private func setupFilterButton() {
        filterButton = UIButton(type: .system)
        filterButton.setTitle(LocalizationHelper.localizedString("filtres"), for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .ypBlue
        filterButton.setTitleColor(.ypWhite, for: .normal)
        filterButton.layer.cornerRadius = 16
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateFilterButtonVisibility()
    }
    
    private func updateFilterButtonVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let hasTrackersForSelectedDate = self.categories.flatMap { $0.trackers }.contains { tracker in
                if let schedule = tracker.schedule, !schedule.isEmpty {
                    return schedule.contains { $0 == WeekDay.from(date: self.datePicker.date) }
                } else if let creationDate = self.trackerCreationDates[tracker.id] {
                    return Calendar.current.isDate(creationDate, inSameDayAs: self.datePicker.date)
                }
                return false
            }
            
            let noResults = self.filteredCategories.isEmpty && self.isSearching
            
            if noResults && hasTrackersForSelectedDate {
                self.emptyState.isHidden = false
                self.emptyState.configure(with: .noResults, labelHeight: 20)
                self.filterButton.isHidden = false
            } else if !hasTrackersForSelectedDate {
                self.emptyState.isHidden = false
                self.emptyState.configure(with: .noTrackers, labelHeight: 20)
                self.filterButton.isHidden = true
            } else {
                self.emptyState.isHidden = false
                self.emptyState.configure(with: .noResults, labelHeight: 20)
                self.filterButton.isHidden = false
            }
            
            self.collectionView.backgroundView = self.filteredCategories.isEmpty ? self.emptyState : nil
        }
    }
    
    private func applyFilter(_ filter: TrackerFilterHelper) {
        selectedFilter = filter
        
        
        if filter == .today {
            currentDate = Date()
            datePicker.date = currentDate
        }
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        updateFilterButtonAppearance()
    }
    
    private func updateFilterButtonAppearance() {
        if selectedFilter == .all {
            filterButton.setTitleColor(.ypWhite, for: .normal)
            filterButton.setTitle("\(LocalizationHelper.localizedString("filtres"))", for: .normal)
        } else {
            filterButton.backgroundColor = .ypBlue
            filterButton.setTitle("\(LocalizationHelper.localizedString("filtres")) ❇️", for: .normal)
        }
    }
    
    
    init() {
        self.parameters = GeometricParameters(cellCount: 2, leftInsets: 16, rightInsets: 16, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
        
        CoreDataMain.shared.trackerStore.delegate = self
        CoreDataMain.shared.trackerRecordStore.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        setTrackersCollectionView()
        view.backgroundColor = .ypWhite
        setNavigationBar()
        reloadData()
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        setConsrainSearchBar()
        setupFilterButton()
        
        applyFilter(selectedFilter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsService.logEvent(event: "open", screen: "Main")
        print("Event logged: open, screen: Main")
    }
    
    override func viewDidDisappear (_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AnalyticsService.logEvent(event: "close", screen: "Main")
        print("Event logged: close, screen: Main")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
                if let leftView = textFieldInsideSearchBar.leftView as? UIImageView {
                    leftView.tintColor = UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ? .white : .gray
                    }
                }
            }
            setNavigationBar()
            setDatePickerItem()
        }
    }
    
    //MARK: - Helpers
    
    func setNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = LocalizationHelper.localizedString("trackers")
        
        
        let addButton = UIButton(type: .custom)
        if let iconImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal) {
            addButton.setImage(iconImage, for: .normal)
        }
        addButton.titleLabel?.font = UIFont(name: "SF Pro", size: 34)
        addButton.addTarget(
            self,
            action: #selector(addTrackerButtonTapped),
            for: .touchUpInside
        )
        
        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let addButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addButtonItem
        
        setDatePickerItem()
        definesPresentationContext = true
        
        self.datePicker = datePicker
    }
    
    func setDatePickerItem() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        let now = Date()
        let dateWithoutTime = now.removeTimeStamp
        datePicker.date = dateWithoutTime ?? Date()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.clipsToBounds = true
        datePicker.layer.cornerRadius = 8
        datePicker.tintColor = .ypBlue
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        datePicker.locale = dateFormatter.locale
        datePicker.calendar = dateFormatter.calendar
        
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = -100
        let maxDate = calendar.date(byAdding: dateComponents, to: date)
        dateComponents.year = 100
        let minDate = calendar.date(byAdding: dateComponents, to: date)
        datePicker.minimumDate = maxDate
        datePicker.maximumDate = minDate
        
        currentDate = datePicker.date
        print("Текущее значение currentDate: \(dateFormatter.string(from: currentDate))")
        
        let widthConstraint = NSLayoutConstraint(
            item: datePicker,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 120
        )
        
        datePicker.addConstraint(widthConstraint)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    func deleteTracker(trackerId: UUID) {
        CoreDataMain.shared.trackerStore.deleteTrackerAndRecords(trackerId: trackerId)
        reloadData()
    }
    
    private func reloadData() {
        categories = CoreDataMain.shared.trackerStore.fetchTrackersGroupedByCategory()
        
        guard let fetchedObjects = CoreDataMain.shared.trackerStore.fetchedResultsController.fetchedObjects else { return }
        
        trackerCreationDates = fetchedObjects.reduce(into: [:]) { dict, tracker in
            if let id = tracker.id, let creationDate = tracker.creationDate {
                dict[id] = creationDate
            }
        }
        dateChanged()
        collectionView.reloadData()
    }
    
    private func categoriseTrackers(trackers: [Tracker]) -> [TrackerCategory] {
        var categoriesDict: [String: [Tracker]] = [:]
        
        for tracker in trackers {
            let categoryTitle = tracker.schedule?.isEmpty ?? true ? "Нерегулярные события" : "По умолчанию"
            if categoriesDict[categoryTitle] == nil {
                categoriesDict[categoryTitle] = []
            }
            categoriesDict[categoryTitle]?.append(tracker)
        }
        return categoriesDict.map { TrackerCategory(header: $0.key, trackers: $0.value) }
    }
    
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        guard let trackerCoreData = CoreDataMain.shared.trackerStore.fetchTracker(by: tracker.id) else { return false }
        return trackerCoreData.category?.header == LocalizationHelper.localizedString("pinned")
    }
    
    private func setConsrainSearchBar() {
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func pinTracker(_ tracker: Tracker) {
  
        CoreDataMain.shared.trackerStore.pinTracker(tracker.id)
        reloadData()
    }
    
    func unpinTracker(_ tracker: Tracker) {
        CoreDataMain.shared.trackerStore.unpinTracker(tracker.id)
        reloadData()
    }
    
    func togglePinTracker(tracker: Tracker, at indexPath: IndexPath) {
        if isTrackerPinned(tracker) {
            unpinTracker(tracker)
        } else {
            pinTracker(tracker)
        }
        collectionView.reloadData()
    }
    
    @objc private func addTrackerButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "add_track")
        print("Event logged: click, screen: Main, item: add_track")
        
        let trackerTypeVC = AddTrackerViewController()
        trackerTypeVC.delegate = self
        trackerTypeVC.habitCreationDelegate = self
        trackerTypeVC.modalPresentationStyle = .pageSheet
        present(trackerTypeVC, animated: true)
    }
    
    @objc private func selectFilter() {
        print("Filtres applied")
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "filter")
        print("Event logged: click, screen: Main, item: filter")
        let filtersVC = FiltersViewController()
        filtersVC.selectedFilter = selectedFilter
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.onSelectFilter = { [weak self] filter in
            self?.selectedFilter = filter
            self?.applyFilter(filter)
            self?.dismiss(animated: false, completion: nil)
        }
        present(filtersVC, animated: true)
    }
    
    @objc private func dateChanged() {
        let weekday = WeekDay.from(date: datePicker.date)
        print("День недели для даты \(datePicker.date): \(weekday?.asText() ?? "нет данных")")
        updateDateLabelTitle(with: datePicker.date)
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        
        reloadPlaceholder()
        updateFilterButtonVisibility()
        
        currentDate = datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        print("Текущее значение currentDate: \(dateFormatter.string(from: currentDate))")
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString
    }
    
    func reloadFilteredCategories(text: String?, date: Date) {
        let filterText = (text ?? "").lowercased()
        let filterWeekday = WeekDay.from(date: date)
        
        let textFilteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                filterText.isEmpty || tracker.title.lowercased().contains(filterText)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filteredTrackers)
        }
        
        if let filterWeekday = filterWeekday {
            filteredCategories = textFilteredCategories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    guard let trackerCoreData = CoreDataMain.shared.trackerStore.convertToCoreData(tracker: tracker) else {
                        return false
                    }
                    let isCompletedToday = CoreDataMain.shared.trackerRecordStore.isTrackerCompletedToday(tracker: trackerCoreData, date: date)
                    let matchesFilter: Bool
                    switch selectedFilter {
                    case .completed:
                        matchesFilter = isCompletedToday
                    case .uncompleted:
                        matchesFilter = !isCompletedToday
                    case .today, .all:
                        matchesFilter = true
                    }
                    
                    if !matchesFilter {
                        return false
                    }
                    
                    if tracker.schedule?.isEmpty ?? true {
                        if let creationDate = trackerCreationDates[tracker.id], Calendar.current.isDate(creationDate, inSameDayAs: date) {
                            return !completedIrregularEvents.contains(tracker.id)
                        } else {
                            return false
                        }
                    }
                    return tracker.schedule!.contains(filterWeekday)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
        } else {
            filteredCategories = textFilteredCategories
        }
        updateFilterButtonVisibility()
        
        collectionView.reloadData()
        reloadPlaceholder()
        
        updateFilterButtonVisibility()
    }
    
    private func reloadPlaceholder() {
        emptyState.isHidden = !filteredCategories.isEmpty
        collectionView.backgroundView = filteredCategories.isEmpty ? emptyState : nil
    }
    
    private func setTrackersCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.cellIdentifier
        )
        
        collectionView.register(
            TrackerCVHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCVHeader.headerIdentifier
        )
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }
}

// MARK: - Extensions

extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        collectionView.reloadData()
        
        return true
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = filteredCategories[section].trackers.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCVHeader.headerIdentifier,
            for: indexPath) as? TrackerCVHeader
        else {
            assertionFailure("Failed to dequeue Trackers Header")
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = filteredCategories[indexPath.section].header
        header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = filteredCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedDaysCount(for: tracker.id)
        
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath,
            isPinned: isTrackerPinned(tracker)
        )
        
        cell.onDelete = { [weak self] in
            let alert = UIAlertController(
                title: LocalizationHelper.localizedString("areYouSure"),
                message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: LocalizationHelper.localizedString("delete"),
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.row]
                
                CoreDataMain.shared.trackerRecordStore.deleteAllTrackerRecords(with: tracker.id)
                CoreDataMain.shared.trackerStore.deleteTrackerAndRecords(trackerId: tracker.id)
                AnalyticsService.logEvent(event: "click", screen: "Main", item: "delete")
                self.reloadData()
            }
            let cancelAction = UIAlertAction(title: LocalizationHelper.localizedString("cancel"), style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true)
        }
        
        cell.onEdit = { [weak self] in
            guard let self = self else { return }
            AnalyticsService.logEvent(event: "click", screen: "Main", item: "edit")
            let category = self.filteredCategories[indexPath.section]
            let tracker = category.trackers[indexPath.row]
            let editHabitVC = CreateHabitViewController(
                tracker: tracker,
                category: category.header
            )
            editHabitVC.delegate = self
            editHabitVC.modalPresentationStyle = .pageSheet
            self.present(editHabitVC, animated: true)
        }
        
        cell.onPin = { [weak self] in
            self?.togglePinTracker(tracker: tracker, at: indexPath)
        }
        
        return cell
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avaliableWidth = collectionView.bounds.width - parameters.paddingWidth
        let widthPerItem = avaliableWidth / CGFloat(parameters.cellCount)
        let heightPerItem = widthPerItem * (148 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: parameters.leftInsets, bottom: 16, right: parameters.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return parameters.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let header: UICollectionReusableView
        let indexPath = IndexPath(row: .zero, section: section)
        if #available(iOS 18.0, *) {
            return CGSize(width: collectionView.bounds.width, height: 18)
        } else {
            header = self.collectionView(collectionView,
                                         viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                         at: indexPath)
        }
        
        
        let size = header.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        return size
    }
}

extension TrackerViewController: TrackersCellDelegate {
    
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "track")
              print("Event logged: click, screen: Main, item: track")
        
        let selectedDate = datePicker.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: id) {
            CoreDataMain.shared.trackerRecordStore.addTrackerRecord(for: tracker, date: selectedDate)
            if tracker.schedule?.isEmpty ?? true {
                completedIrregularEvents.insert(id)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let selectedDate = datePicker.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: id) {
            CoreDataMain.shared.trackerRecordStore.removeTrackerRecord(for: tracker, date: selectedDate)
            if tracker.schedule?.isEmpty ?? true {
                completedIrregularEvents.remove(id)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        if let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: id) {
            return CoreDataMain.shared.trackerRecordStore.isTrackerCompletedToday(tracker: tracker, date: datePicker.date)
        }
        return false
    }
    
    func completedDaysCount(for trackerID: UUID) -> Int {
        if let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerID) {
            return CoreDataMain.shared.trackerRecordStore.completedDaysCount(for: tracker)
        }
        return 0
    }
}

extension TrackerViewController: UISearchBarDelegate  {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TrackerViewController: HabitCreationDelegate {
    func didCreateHabit() {
        reloadData()
    }
}

extension TrackerViewController: TrackerTypeDelegate {
    func showCreateHabit() {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabitViewController(isIrregularEvent: false)
            createHabitVC.delegate = self
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }
    
    func showCreateIrregularEvent() {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabitViewController(isIrregularEvent: true)
            createHabitVC.delegate = self
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate() {
        reloadData()
    }
    func trackerStoreDidAddTracker(_ tracker: TrackerCoreData) {
        reloadData()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdate() {
        reloadData()
    }
}
