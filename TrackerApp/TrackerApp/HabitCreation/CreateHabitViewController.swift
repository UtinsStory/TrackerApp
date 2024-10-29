//
//  CreateHabitViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 06.10.2024.
//

import UIKit

// MARK: - HabitTableViewDelegate
protocol HabitTableViewDelegate: AnyObject {
    func didSelectTimetable()
}

// MARK: - HabitCreationDelegate
protocol HabitCreationDelegate: AnyObject {
    func didCreateHabit(_ habit: Tracker)
}

final class CreateHabitViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Private Properties
    
    private let colors: [UIColor] = [.ypColorSelection1,
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
    
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private var selectedWeekDays: [WeekDay] = []
    
    private var selectedEmoji: String?
    
    private var selectedColor: UIColor?
    
    weak var delegate: HabitCreationDelegate?
    
    var isIrregularEvent: Bool = false
    
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhite
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var habitLabel: UILabel = {
        let newhabitLabel = UILabel()
        newhabitLabel.text = isIrregularEvent ? "Новое нерегулярное событие" : "Новая привычка"
        newhabitLabel.textColor = .ypBlack
        newhabitLabel.textAlignment = .center
        newhabitLabel.font = .systemFont(ofSize: 16)
        newhabitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return newhabitLabel
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textAlignment = .left
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackground
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftIndent
        textField.leftViewMode = .always
        
        let rightIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightIndent
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private lazy var limitMessage: UILabel = {
        let limit = UILabel()
        limit.text = "Ограничение 38 символов"
        limit.textColor = .ypRed
        limit.textAlignment = .center
        limit.font = .systemFont(ofSize: 17, weight: .regular)
        limit.translatesAutoresizingMaskIntoConstraints = false
        
        return limit
    }()
    
    private lazy var stackContent: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CreateHabbitTableViewCell.self,
                           forCellReuseIdentifier: CreateHabbitTableViewCell.cellID
        )
        
        return tableView
    }()
    
    private lazy var creationButton: UIButton = {
        let creation = UIButton()
        creation.setTitle("Создать", for: .normal)
        creation.backgroundColor = .ypGray
        creation.layer.cornerRadius = 16
        creation.translatesAutoresizingMaskIntoConstraints = false
        creation.addTarget(self,
                           action: #selector(createButtonTapped),
                           for: .touchUpInside
        )
        return creation
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.setTitle("Отменить", for: .normal)
        cancel.setTitleColor(.red, for: .normal)
        cancel.backgroundColor = .ypWhite
        cancel.layer.borderWidth = 1
        cancel.layer.cornerRadius = 16
        cancel.layer.borderColor = UIColor.ypRed.cgColor
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self,
                         action: #selector(cancelButtonTapped),
                         for: .touchUpInside
        )
        return cancel
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackerCreationCVHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCreationCVHeader.reuseIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var colorSelectionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorSelectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: ColorSelectionCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackerCreationCVHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCreationCVHeader.reuseIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private let params = GeometricParameters(cellCount: 6, leftInsets: 2, rightInsets: 2, cellSpacing: 5)
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = .ypWhite
        setConstraint()
        setSpacing()
        setLimitSpacing()
        
        limitMessage.isHidden = true
        nameTextField.delegate = self
        
        changeButtonColor()
    }
    
    private func changeButtonColor() {
        
        let isNameFieldNotEmpty = !(nameTextField.text?.isEmpty ?? true)
        let shouldEnableButton: Bool
        
        if isIrregularEvent {
            
            shouldEnableButton = isNameFieldNotEmpty
        } else {
            
            shouldEnableButton = isNameFieldNotEmpty && !selectedWeekDays.isEmpty
        }
        
        if shouldEnableButton {
            creationButton.isEnabled = true
            creationButton.backgroundColor = .ypBlack
        } else {
            creationButton.isEnabled = false
            creationButton.backgroundColor = .ypGray
        }
    }
    
    private func setSpacing() {
        stackContent.setCustomSpacing(38, after: habitLabel)
        stackContent.setCustomSpacing(24, after: nameTextField)
        stackContent.setCustomSpacing(32, after: tableView)
        stackContent.setCustomSpacing(34, after: emojiCollectionView)
        stackContent.setCustomSpacing(16, after: colorSelectionCollectionView)
        
        stackContent.isLayoutMarginsRelativeArrangement = true
        stackContent.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackButtons.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    private func setLimitSpacing() {
        let isMessageHidden = limitMessage.isHidden
        
        let spacingAfterTextField: CGFloat = isMessageHidden ? 8 : 24
        let spacingAfterLimitMessage: CGFloat = isMessageHidden ? 8 : 32
        
        stackContent.setCustomSpacing(spacingAfterTextField, after: nameTextField)
        stackContent.setCustomSpacing(spacingAfterLimitMessage, after: limitMessage)
    }
    
    private func setConstraint() {
        view.addSubview(scrollView)
        view.addSubview(stackButtons)
        scrollView.addSubview(stackContent)
        
        [habitLabel,
         nameTextField,
         limitMessage,
         tableView,
         emojiCollectionView,
         colorSelectionCollectionView
        ].forEach {
            stackContent.addArrangedSubview($0)
        }
        
        [cancelButton,
         creationButton
        ].forEach {
            stackButtons.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackButtons.topAnchor),
            
            stackContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            stackContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            habitLabel.topAnchor.constraint(equalTo: stackContent.topAnchor, constant: 27),
            
            habitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            limitMessage.heightAnchor.constraint(equalToConstant: 22),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 250),
            colorSelectionCollectionView.heightAnchor.constraint(equalToConstant: 250),
            
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Action
    
    @objc private func createButtonTapped() {
        let habitName = nameTextField.text ?? ""
        
        let randomNumber = Int.random(in: 1...18)
        let randomColor = colors[randomNumber - 1]
        let randomEmoji = emojis[randomNumber - 1]
        
        let selectedColorHex = selectedColor?.toHexString() ?? randomColor.toHexString()
        let selectedEmoji = self.selectedEmoji ?? randomEmoji

        
        let newHabit = Tracker(
            id: UUID(),
            title: habitName,
            color: selectedColorHex,
            emoji: selectedEmoji,
            schedule: selectedWeekDays
        )
        
        delegate?.didCreateHabit(newHabit)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isIrregularEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CreateHabbitTableViewCell.cellID,
            for: indexPath) as? CreateHabbitTableViewCell else {
            assertionFailure("Could not cast to CreateHabitCell")
            return UITableViewCell()
        }
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", subtitle: "По умолчанию", isLastCell: isLastCell)
        } else if indexPath.row == 1 {
            cell.configureCell(with: "Расписание", subtitle: "", isLastCell: isLastCell)
        }
        
        if isLastCell {
            cell.hideSeparator()
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.showSeparator()
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        limitMessage.isHidden = !(updatedText.count > 38)
        changeButtonColor()
        return updatedText.count <= 38
    }
}

// MARK: - UITableViewDelegate
extension CreateHabitViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.modalPresentationStyle = .pageSheet
            scheduleVC.delegate = self
            self.present(scheduleVC, animated: true, completion: nil)
        }
    }
}

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func didUpdateSchedule(selectedDays: [WeekDay], displayText: String) {
        self.selectedWeekDays = selectedDays
        
        let indexPath = IndexPath(row: 1, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? CreateHabbitTableViewCell {
            cell.subtitleLabel.text = displayText.isEmpty ? "" : displayText
        }
        changeButtonColor()
    }
}

//MARK: - UICollectionViewDelegate
extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = (params.cellSpacing * CGFloat(params.cellCount - 1)) + params.leftInsets + params.rightInsets
        let availableWidth = collectionView.bounds.width - totalSpacing
        let widthPerItem = availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInsets, bottom: 24, right: params.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
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

//MARK: - UICollectionViewDataSource
extension CreateHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
                for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell()}
            
            let emoji = emojis[indexPath.item]
            cell.setEmoji(emoji)
            
            return cell
        } else if collectionView == colorSelectionCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorSelectionCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ColorSelectionCollectionViewCell else { return UICollectionViewCell()}
            
            let color = colors[indexPath.item]
            cell.setColor(color)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCreationCVHeader.reuseIdentifier,
            for: indexPath) as? TrackerCreationCVHeader
        else {
            return UICollectionReusableView()
        }
        
        if collectionView == emojiCollectionView {
            header.setHeaderLabelText("Emoji")
        } else if collectionView == colorSelectionCollectionView {
            header.setHeaderLabelText("Цвет")
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            selectedEmoji = emojis[indexPath.item]
            
            selectedCell?.selectEmoji()
        } else if collectionView == colorSelectionCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? ColorSelectionCollectionViewCell
            selectedColor = colors[indexPath.item]
            
            selectedCell?.selectColor()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            deselectedCell?.deselectEmoji()
            
        } else if collectionView == colorSelectionCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? ColorSelectionCollectionViewCell
            deselectedCell?.deselectColor()
        }
    }
}

