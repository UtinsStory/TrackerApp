//
//  CreateIrregularEventViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 10.10.2024.
//
import UIKit

final class CreateIrregularEventViewController: UIViewController {
    // MARK: - Public Properties
    var trackerVC: TrackerViewController?
    let IECellReuseIdentifier = "IETableViewCell"
    // MARK: - Private Properties
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новое нерегулярное событие"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlack
        
        return header
    }()
    
    private let addEventName: UITextField = {
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
    
    private lazy var irregularEventTableView: UITableView = {
        let irregularEventTableView = UITableView()
        irregularEventTableView.translatesAutoresizingMaskIntoConstraints = false
        irregularEventTableView.delegate = self
        irregularEventTableView.dataSource = self
        irregularEventTableView.register(CreateIrregularEventTableViewCell.self, forCellReuseIdentifier: IECellReuseIdentifier)
        
        return irregularEventTableView
    }()
    
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
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        view.addSubviews([header, addEventName, stackButtons, irregularEventTableView])
        
        irregularEventTableView.layer.cornerRadius = 16
        irregularEventTableView.separatorStyle = .none
        
        [cancelButton, createButton].forEach { stackButtons.addArrangedSubview($0)}
        
        addEventName.delegate = self
        
        NSLayoutConstraint.activate([
            
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addEventName.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addEventName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addEventName.heightAnchor.constraint(equalToConstant: 75),
            addEventName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addEventName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            irregularEventTableView.topAnchor.constraint(equalTo: addEventName.bottomAnchor, constant: 24),
            irregularEventTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventTableView.heightAnchor.constraint(equalToConstant: 75),
            
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
        
        
    }
    
    // MARK: - Public Methods
    @objc
    func createButtonTapped() {
        guard let eventName = addEventName.text, !eventName.isEmpty else {
            return
        }
        let newEvent = Tracker(id: UUID(),
                                 title: eventName,
                                 color: colors[Int.random(in: 0..<self.colors.count)],
                                 emoji: emojies[Int.random(in: 0..<self.emojies.count)],
                                 schedule: nil)
        trackerVC?.addTracker(tracker: newEvent)
        trackerVC?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc
    func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
//MARK: - UITextFieldDelegate
extension CreateIrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        }
    }
}

//MARK: - UITableViewDelegate
extension CreateIrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        irregularEventTableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CreateIrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IECellReuseIdentifier,
                                                       for: indexPath) as? CreateIrregularEventTableViewCell
        else {
            return UITableViewCell()
        }
        
        cell.update(with: "Категория")
        
        return cell
    }
    
}

