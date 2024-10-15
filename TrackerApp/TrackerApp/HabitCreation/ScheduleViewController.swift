//
//  ScheduleViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 07.10.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Public Properties
    var createHabitVC: CreateHabitViewController?
    let scheduleCellReuseIdentifier = "ScheduleTableViewCell"
    
    // MARK: - Private Properties
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Расписание"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlack
        
        return header
    }()
    
    private let scheduleTableView: UITableView = {
        let scheduleTableView = UITableView()
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        return scheduleTableView
    }()
    
    private lazy var doneScheduleButton: UIButton = {
        let doneScheduleButton = UIButton(type: .custom)
        doneScheduleButton.setTitle("Готово", for: .normal)
        doneScheduleButton.setTitleColor(.ypWhite, for: .normal)
        doneScheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneScheduleButton.backgroundColor = .ypBlack
        doneScheduleButton.layer.cornerRadius = 16
        doneScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        doneScheduleButton.addTarget(self, action: #selector(doneScheduleButtonDidTap), for: .touchUpInside)
        
        return doneScheduleButton
    }()
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        view.addSubviews([header, scheduleTableView, doneScheduleButton])
        
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleTableViewCell.self,
                                   forCellReuseIdentifier: scheduleCellReuseIdentifier)
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.separatorStyle = .none
        
        setUpConstraints()
    }
    // MARK: - Public Methods
    @objc
    func doneScheduleButtonDidTap() {
        var selected: [Int] = []
        for (index, element) in scheduleTableView.visibleCells.enumerated() {
            guard let cell = element as? ScheduleTableViewCell else { return }
            
            if cell.selectedDay {
                selected.append(index)
            }
            self.createHabitVC?.saveDay(indicies: selected)
            dismiss(animated: true)
        }
    }
    // MARK: - Private Methods
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 524),
            doneScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneScheduleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .ypGray
        
        cell.addSubview(separatorView)
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        scheduleTableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellReuseIdentifier, for: indexPath) as? ScheduleTableViewCell else { return UITableViewCell() }
        
        let dayofTheWeek = WeekDay.allCases[indexPath.row]
        cell.update(with: "\(dayofTheWeek.name)")
        
        return cell
    }
}
