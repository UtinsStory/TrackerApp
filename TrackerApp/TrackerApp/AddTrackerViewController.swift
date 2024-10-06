//
//  TrackersCreationViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var trackerVC: TrackerViewController?
    // MARK: - Private Properties
    private lazy var header: UILabel = {
        let header = UILabel()
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Создание трекера"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlack
        
        return header
    }()
    
    private lazy var habitButton: UIButton = {
        let habitButton = UIButton(type: .custom)
        view.addSubview(habitButton)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.setTitleColor(.ypWhite, for: .normal)
        habitButton.backgroundColor = .ypBlack
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        
        return habitButton
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let irregularEventButton = UIButton(type: .custom)
        view.addSubview(irregularEventButton)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.setTitleColor(.ypWhite, for: .normal)
        irregularEventButton.backgroundColor = .ypBlack
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        return irregularEventButton
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        NSLayoutConstraint.activate([
                   view.topAnchor.constraint(equalTo: view.topAnchor),
                   view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                   header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
                   header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   habitButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 295),
                   habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   habitButton.heightAnchor.constraint(equalToConstant: 60),
                   irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
                   irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
                   ])
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    @objc
    func habitButtonTapped() {
        
    }
    
    @objc
    func irregularEventButtonTapped() {
        
    }
    // MARK: - Private Methods
}
