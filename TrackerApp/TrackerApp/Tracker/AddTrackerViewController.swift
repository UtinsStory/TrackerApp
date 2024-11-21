//
//  TrackersCreationViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

protocol TrackerTypeDelegate: AnyObject {
    func showCreateHabit()
    func showCreateIrregularEvent()
}

final class AddTrackerViewController: UIViewController {
    
    weak var delegate: TrackerTypeDelegate?
    weak var habitCreationDelegate: HabitCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setLabel()
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        let buttonHabbit = createButton(title: LocalizationHelper.localizedString("habit"),
                                        action: #selector(habitButtonTaped))
        stackView.addArrangedSubview(buttonHabbit)
 
        let buttonOneEvent = createButton(title: LocalizationHelper.localizedString("irregularEvent"),
                                          action: #selector(irregularEventButtonTaped))
        stackView.addArrangedSubview(buttonOneEvent)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 344),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    @objc private func habitButtonTaped() {
        delegate?.showCreateHabit()
    }
    
    @objc private func irregularEventButtonTaped() {
        delegate?.showCreateIrregularEvent()
    }
    
    private func setLabel() {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("trackerCreation")
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
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }
}
