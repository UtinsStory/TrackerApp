//
//  ScheduleViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 07.10.2024.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(selectedDays: [WeekDay], displayText: String)
}

final class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: ScheduleViewControllerDelegate?
    private let tableView = UITableView()
    private let daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var switchStates: [Bool] = [false, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        view.backgroundColor = .ypWhite
        setLabel()
        setTableView()
        
        let buttonDone = createButton(title: "Готово", action: #selector(buttonDoneTapped))
        view.addSubview(buttonDone)
        
        NSLayoutConstraint.activate([
            buttonDone.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            buttonDone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonDone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func isEverydaySelected(_ days: [WeekDay]) -> Bool {
        return Set(days) == Set(WeekDay.allCases)
    }
    
    private func isWeekdaysSelected(_ days: [WeekDay]) -> Bool {
        let weekdays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        return Set(days) == weekdays
    }
    
    private func isWeekendSelected(_ days: [WeekDay]) -> Bool {
        let weekend: Set<WeekDay> = [.saturday, .sunday]
        return Set(days).isSubset(of: weekend)
    }
    
    private func getDisplayText(for days: [WeekDay]) -> String {
        if isEverydaySelected(days) {
            return "Каждый день"
        } else if isWeekdaysSelected(days) {
            return "Будние дни"
        } else if isWeekendSelected(days) {
            return "Выходные дни"
        } else {
            return days.map { $0.asShortText() }.joined(separator: ", ")
        }
    }
    
    private func updateSchedule() {
        let selectedDays = getSelectedDays()
        let displayText = getDisplayText(for: selectedDays)
        delegate?.didUpdateSchedule(selectedDays: selectedDays, displayText: displayText)
    }
    
    private func getSelectedDays() -> [WeekDay] {
        return daysOfWeek.enumerated().compactMap { index, _ in
            return switchStates[index] ? WeekDay(rawValue: index + 1) : nil
        }
    }
    
    private func setLabel() {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, at: indexPath)
        
        if indexPath.row == daysOfWeek.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundColor = .ypBackground
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let dayOfWeek = daysOfWeek[indexPath.row]
        cell.textLabel?.text = dayOfWeek
        
        let switcher = UISwitch()
        switcher.isOn = switchStates[indexPath.row]
        switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switcher
        cell.selectionStyle = .none
        switcher.onTintColor = .ypBlue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        }
        
        if indexPath.row == daysOfWeek.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        }
    }
    
    func indexPathForView(_ view: UIView) -> IndexPath? {
        let point = view.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: point)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if let indexPath = indexPathForView(sender) {
            switchStates[indexPath.row] = sender.isOn
        }
    }
    
    @objc private func buttonDoneTapped() {
        updateSchedule()
        dismiss(animated: true, completion: nil)
    }
}
