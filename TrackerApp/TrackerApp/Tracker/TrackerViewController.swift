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

    private lazy var emptyState: PlaceholderView = {
        let placeholder = PlaceholderView()
        return placeholder
    }()

    init() {
        self.parameters = GeometricParameters(cellCount: 2, leftInsets: 16, rightInsets: 16, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
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
    }

    //MARK: - Helpers

    func setNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Трекеры"

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

    private func reloadData() {
        
    }

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
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        return searchBar
    }()

    private func setConsrainSearchBar() {
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    @objc private func addTrackerButtonTapped() {
        let trackerTypeVC = AddTrackerViewController()
        trackerTypeVC.delegate = self
        trackerTypeVC.habitCreationDelegate = self
        trackerTypeVC.modalPresentationStyle = .pageSheet
        present(trackerTypeVC, animated: true)
    }

    @objc private func selectFilter() {
        print("Filtres applied")
    }

    @objc private func dateChanged() {
        let weekday = WeekDay.from(date: datePicker.date)
        print("День недели для даты \(datePicker.date): \(weekday?.asText() ?? "нет данных")")
        updateDateLabelTitle(with: datePicker.date)
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        
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

        collectionView.reloadData()
        reloadPlaceholder()
    }

    private func reloadPlaceholder() {
        emptyState.isHidden = !filteredCategories.isEmpty
        collectionView.backgroundView = filteredCategories.isEmpty ? emptyState : nil
    }

    private func setTrackersCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
            fatalError("Failed to dequeue Trackers Header")
        }

        header.titleLabel.text = filteredCategories[indexPath.section].header
        header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count

        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }

    private func isTrackerCompletedToday(id: UUID) -> Bool {
        return completedTrackers.contains(where: { isSameTrackerRecord(trackerRecord: $0, id: id) })
    }

    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        return trackerRecord.id == id && Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        let selectedDate = datePicker.date
        let currentDate = Date()

        if selectedDate > currentDate {
            return
        }

//        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
//        completedTrackers.append(trackerRecord)
//        completedTrackerIDs.insert(id)

        if let tracker = categories.flatMap({ $0.trackers }).first(where: { $0.id == id }), tracker.schedule?.isEmpty ?? true {
            completedIrregularEvents.insert(id)
        }

        collectionView.reloadItems(at: [indexPath])
    }

    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let selectedDate = datePicker.date
        let currentDate = Date()

        if selectedDate > currentDate {
            return
        }

        if let index = completedTrackers.firstIndex(where: { isSameTrackerRecord(trackerRecord: $0, id: id) }) {
            completedTrackers.remove(at: index)
        }
        completedTrackerIDs.remove(id)
        collectionView.reloadItems(at: [indexPath])
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
    func didCreateHabit(_ habit: Tracker) {
        trackerCreationDates[habit.id] = Date()

        if habit.schedule?.isEmpty ?? true {
            if let index = categories.firstIndex(where: { $0.header == "Нерегулярные события" }) {
                var updatedTrackers = categories[index].trackers
                updatedTrackers.append(habit)
                let updatedCategory = TrackerCategory(header: "Нерегулярные события", trackers: updatedTrackers)
                categories[index] = updatedCategory
            } else {
                let newCategory = TrackerCategory(header: "Нерегулярные события", trackers: [habit])
                categories.append(newCategory)
            }
        } else {
            if let index = categories.firstIndex(where: { $0.header == "По умолчанию" }) {
                var updatedTrackers = categories[index].trackers
                updatedTrackers.append(habit)
                let updatedCategory = TrackerCategory(header: "По умолчанию", trackers: updatedTrackers)
                categories[index] = updatedCategory
            } else {
                let newCategory = TrackerCategory(header: "По умолчанию", trackers: [habit])
                categories.append(newCategory)
            }
        }
        reloadFilteredCategories(text: searchBar.text, date: datePicker.date)
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerTypeDelegate {
    func showCreateHabit() {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabitViewController()
            createHabitVC.delegate = self
            createHabitVC.isIrregularEvent = false
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }

    func showCreateIrregularEvent() {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabitViewController()
            createHabitVC.delegate = self
            createHabitVC.isIrregularEvent = true
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }
}
