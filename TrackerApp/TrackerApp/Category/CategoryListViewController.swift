//
//  CategoryListViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 14.11.2024.
//

import UIKit

protocol CategoryListViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryListViewController: UIViewController {
    
    weak var delegate: CategoryListViewControllerDelegate?
    
    private let viewModel = CategoryListViewModel()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("category")
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.backgroundColor = .ypWhite

        return tableView
    }()

    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.setTitle(LocalizationHelper.localizedString("addCategoryButtonText"), for: .normal)
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.addTarget(self,
                                    action: #selector(addCategoryButtonTapped),
                                    for: .touchUpInside
        )
        return addCategoryButton
    }()

    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableView.separatorStyle = .none
        bindViewModel()
    }

    private func hideSeparator() {
        customSeparatorView.isHidden = true
    }

    private func showSeparator() {
        customSeparatorView.isHidden = false
    }

    private func setLabel() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupAddCategoryButton() {
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
        ])
    }

    private func setNoCategory() {
 
        let noResultsLabel = UILabel()
        let text = LocalizationHelper.localizedString("noCategoryText")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        noResultsLabel.attributedText = attributedString
        noResultsLabel.textColor = .ypBlack
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        noResultsLabel.numberOfLines = 2
        noResultsLabel.lineBreakMode = .byWordWrapping
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(noResultsLabel)

        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let noResultsImageView = UIImageView(image: UIImage(named: "empty"))
        noResultsImageView.contentMode = .scaleAspectFit
        noResultsImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(noResultsImageView)

        NSLayoutConstraint.activate([
            noResultsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsImageView.bottomAnchor.constraint(equalTo: noResultsLabel.topAnchor, constant: -8),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 80),
            noResultsImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func updateEmptyState() {
        if viewModel.categories.isEmpty {
            setNoCategory()
        } else {
            removeNoCategory()
        }
    }

    private func removeNoCategory() {
        view.subviews.forEach { view in
            if let label = view as? UILabel, label.text?.contains(LocalizationHelper.localizedString("noCategoryText")) == true {
                view.removeFromSuperview()
            } else if let imageView = view as? UIImageView, imageView.image == UIImage(named: "empty") {
                view.removeFromSuperview()
            }
        }
    }

    private func setUI() {
        view.backgroundColor = .ypWhite
        setLabel()
        setTableView()
        setupAddCategoryButton()
    }

    private func bindViewModel() {
        viewModel.onViewStateUpdated = { [weak self] state in
            switch state {
            case .empty:
                self?.setNoCategory()
            case .populated:
                self?.removeNoCategory()
                self?.tableView.reloadData()
            }
        }

        viewModel.loadCategories()
    }

    @objc private func addCategoryButtonTapped() {
        let categoryCreationVC = CategoryCreationViewController()
        categoryCreationVC.onCategoryAdded = { [weak self] categoryName in
            self?.viewModel.categories.append(TrackerCategory(header: categoryName, trackers: []))
        }
        self.present(categoryCreationVC, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, at: indexPath)

        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }

    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = viewModel.categories[indexPath.row].header
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackground

        cell.contentView.subviews.forEach { view in
            if view.backgroundColor == .ypGray && view.frame.height == 0.5 {
                view.removeFromSuperview()
            }
        }

        if indexPath.row != viewModel.categories.count - 1 {
            let separatorView = UIView()
            separatorView.backgroundColor = .ypGray
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separatorView)

            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                separatorView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }

        if viewModel.categories.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }

        cell.contentView.subviews.forEach { view in
            if view is UIImageView {
                view.removeFromSuperview()
            }
        }

        if indexPath == viewModel.selectedIndex {
            let checkboxIcon = UIImageView()
            checkboxIcon.image = UIImage(named: "tracker_done")
            checkboxIcon.contentMode = .scaleAspectFit
            checkboxIcon.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(checkboxIcon)

            NSLayoutConstraint.activate([
                checkboxIcon.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                checkboxIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                checkboxIcon.widthAnchor.constraint(equalToConstant: 24),
                checkboxIcon.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Выбрана категория: \(viewModel.categories[indexPath.row].header)")

        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
        delegate?.didSelectCategory(viewModel.categories[indexPath.row].header)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

}
