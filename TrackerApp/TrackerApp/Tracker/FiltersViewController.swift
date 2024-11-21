//
//  FiltersViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 21.11.2024.
//

import UIKit

final class FiltersViewController: UIViewController {
    var onSelectFilter: ((TrackerFilterHelper) -> Void)?
        var selectedFilter: TrackerFilterHelper = .all

        private var selectedIndex: IndexPath?
        private var previouslySelectedIndex: IndexPath?
        private let allFilters = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
        private let filterTypes: [TrackerFilterHelper] = [.all, .today, .completed, .uncompleted]

        // MARK: - UI Components

        // Заголовок страницы
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Фильтры"
            label.textColor = .ypBlack
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        // Таблица для списка категорий
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

        // Разделитель кастомный
        private lazy var customSeparatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .ypGray
            view.translatesAutoresizingMaskIntoConstraints = false

            return view
        }()

        // MARK: - Lifecycle Methods

        override func viewDidLoad() {
            super.viewDidLoad()
            setUI()
            tableView.separatorStyle = .none
        }

        // MARK: - Private Methods

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

        private func setTableView() {
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            ])
        }

        private func setUI() {
            view.backgroundColor = .ypWhite
            setLabel()
            setTableView()
        }
    }

    // MARK: - UITableViewDataSource

    extension FiltersViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return allFilters.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            configureCell(cell, at: indexPath)

            if indexPath.row == allFilters.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
            return cell
        }

        func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
            cell.textLabel?.text = allFilters[indexPath.row]
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.backgroundColor = .ypBackground

            cell.contentView.subviews.forEach { view in
                if view.backgroundColor == .ypGray && view.frame.height == 0.5 {
                    view.removeFromSuperview()
                }
            }

            if indexPath.row != allFilters.count - 1 {
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

            if allFilters.count == 1 {
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.layer.masksToBounds = true
            } else if indexPath.row == 0 {
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.layer.masksToBounds = true
            } else if indexPath.row == allFilters.count - 1 {
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

            let currentFilter = filterTypes[indexPath.row]
            if currentFilter == selectedFilter {
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

    extension FiltersViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 75
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)

            selectedIndex = indexPath
            tableView.reloadData()

            let selectedFilter = filterTypes[indexPath.row]
            onSelectFilter?(selectedFilter)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

