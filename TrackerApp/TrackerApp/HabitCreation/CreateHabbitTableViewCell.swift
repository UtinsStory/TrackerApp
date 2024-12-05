//
//  CreateHabbitTableViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 07.10.2024.
//
import UIKit

final class CreateHabbitTableViewCell: UITableViewCell {
    
    static let cellID = String(describing: CreateHabbitTableViewCell.self)
    private var isLastCell: Bool = false
    weak var delegate: HabitTableViewDelegate?
    
    // MARK: - Private Properties
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = .ypBlack
        title.font = .systemFont(ofSize: 16, weight: .regular)
        return title
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var arrowIcon: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "chevron")
        arrow.contentMode = .scaleAspectFit
        return arrow
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackground
        addElements()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [stackView,
         arrowIcon,
         customSeparatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = []
    }
    
    // MARK: - Private Methods
    private func roundBottomCorners() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.bottomLeft, .bottomRight],
                                      cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = maskLayer
    }
    
    // MARK: - Private Methods
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            customSeparatorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            arrowIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    func hideSeparator() {
        customSeparatorView.isHidden = true
    }
    
    func showSeparator() {
        customSeparatorView.isHidden = false
    }
    
    func configureCell(with title: String, subtitle: String?, isLastCell: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            if !stackView.arrangedSubviews.contains(subtitleLabel) {
                stackView.addArrangedSubview(subtitleLabel)
            }
        } else {
            stackView.removeArrangedSubview(subtitleLabel)
            subtitleLabel.removeFromSuperview()
        }
    }
}

extension CreateHabbitTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let selectedCell = tableView.cellForRow(at: indexPath) as? CreateHabbitTableViewCell,
               let titleText = selectedCell.titleLabel.text,
               titleText == LocalizationHelper.localizedString("schedule") {
                delegate?.didSelectTimetable()
            }
        }
    }
}

