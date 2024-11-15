//
//  CategoryCreationViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 14.11.2024.
//

import UIKit

final class CategoryCreationViewController: UIViewController {

    var onCategoryAdded: ((String) -> Void)?
    private var viewModel = CategoryCreationViewModel()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("newCategory")
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = LocalizationHelper.localizedString("enterCategoryName")
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

        textField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)

        return textField
    }()

    private lazy var creationButton: UIButton = {
        let creation = UIButton()
        creation.setTitle(LocalizationHelper.localizedString("doneButtonText"), for: .normal)
        creation.backgroundColor = .ypGray
        creation.layer.cornerRadius = 16
        creation.translatesAutoresizingMaskIntoConstraints = false
        creation.addTarget(self,
                           action: #selector(creationButtonTapped),
                           for: .touchUpInside
        )
        return creation
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupCreationButton()
        setupNameTextField()
        bindViewModel()
        validateInitialButtonState()
    }

    // MARK: - Binding ViewModel

    private func bindViewModel() {
        viewModel.onCategoryCreation = { [weak self] categoryName in
            self?.onCategoryAdded?(categoryName)
            self?.dismiss(animated: true, completion: nil)
        }

        viewModel.onCreationButtonStateUpdated = { [weak self] isEnabled in
            self?.creationButton.isEnabled = isEnabled
            self?.creationButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        }
    }

    private func setupTitleLabel() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupNameTextField() {
        view.addSubview(nameTextField)
        nameTextField.delegate = self

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupCreationButton() {
        view.addSubview(creationButton)

        creationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            creationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creationButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }


    private func validateInitialButtonState() {
        viewModel.validateCategoryName(nameTextField.text)
    }


    @objc private func creationButtonTapped() {
        if let categoryName = nameTextField.text, !categoryName.isEmpty {
            viewModel.addCategory(name: categoryName)
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.validateCategoryName(textField.text)
    }
}

// MARK: - UITextFieldDelegate

extension CategoryCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
