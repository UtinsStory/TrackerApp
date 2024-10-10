//
//  CreateHabitViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 06.10.2024.
//

import UIKit

final class CreateHabitViewController: UIViewController {
    // MARK: - Public Properties
    var trackersVC: TrackerViewController?
    let cellReuseIdentifier = "CreateHabbitTableViewCell"
    // MARK: - Private Properties
    private var selectedDays: [WeekDay] = []
    private var colors: [UIColor] = [.ypColorSelection1,
                                     .ypColorSelection2,
                                     .ypColorSelection3,
                                     .ypColorSelection4,
                                     .ypColorSelection5,
                                     .ypColorSelection6,
                                     .ypColorSelection7,
                                     .ypColorSelection8,
                                     .ypColorSelection9,
                                     .ypColorSelection10,
                                     .ypColorSelection11,
                                     .ypColorSelection12,
                                     .ypColorSelection13,
                                     .ypColorSelection14,
                                     .ypColorSelection15,
                                     .ypColorSelection16,
                                     .ypColorSelection17,
                                     .ypColorSelection18]
    
    private let emojies: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новая привычка"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlack
        
        return header
    }()
    
    private let addTrackerName: UITextField = {
        let addTrackerName = UITextField()
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .ypBackground
        addTrackerName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addTrackerName.leftView = leftView
        addTrackerName.leftViewMode = .always
        addTrackerName.keyboardType = .default
        addTrackerName.returnKeyType = .done
        addTrackerName.becomeFirstResponder()
        
        return addTrackerName
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .custom)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        return createButton
    }()
    
    private lazy var stackButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var habitTableView: UITableView = {
        let habitTableView = UITableView()
        habitTableView.translatesAutoresizingMaskIntoConstraints = false
        habitTableView.delegate = self
        habitTableView.dataSource = self
        habitTableView.register(CreateHabbitTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        return habitTableView
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addTrackerName.delegate = self
        
        
        
        view.addSubview(header)
        view.addSubview(addTrackerName)
        view.addSubview(stackButtons)
        view.addSubview(habitTableView)
        habitTableView.layer.cornerRadius = 16
        [cancelButton, createButton].forEach { stackButtons.addArrangedSubview($0)}
        NSLayoutConstraint.activate([
            
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addTrackerName.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTrackerName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addTrackerName.heightAnchor.constraint(equalToConstant: 75),
            addTrackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTrackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            habitTableView.topAnchor.constraint(equalTo: addTrackerName.bottomAnchor, constant: 24),
            habitTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitTableView.heightAnchor.constraint(equalToConstant: 149),
            
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
    }
    
    // MARK: - Public Methods
    @objc
    func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    func createButtonTapped() {
        guard let trackerName = addTrackerName.text, !trackerName.isEmpty else {
            return
        }
        let newTracker = Tracker(id: UUID(),
                                 title: trackerName,
                                 color: colors[Int.random(in: 0..<self.colors.count)],
                                 emoji: emojies[Int.random(in: 0..<self.emojies.count)],
                                 schedule: self.selectedDays)
        trackersVC?.addTracker(tracker: newTracker)
        trackersVC?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    func saveDay(indicies: [Int]) {
        for index in indicies {
            self.selectedDays.append(WeekDay.allCases[index])
        }
    }
    // MARK: - Private Methods
    
    
    
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UITableViewDelegate
extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.modalPresentationStyle = .pageSheet
            
            self.present(scheduleVC, animated: true)

        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .ypGray
        cell.addSubview(separatorView)
    }
}

//MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CreateHabbitTableViewCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.update(with: "Категория")
        } else if indexPath.row == 1 {
            cell.update(with: "Расписание")
        }
        return cell
    }
    
}
