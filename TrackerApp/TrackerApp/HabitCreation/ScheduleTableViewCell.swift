//
//  ScheduleTableViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 08.10.2024.
//
import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    var selectedDay: Bool = false
    // MARK: - Private Properties
    private let dayOfTheWeek: UILabel = {
        let dayOfTheWeek = UILabel()
        dayOfTheWeek.font = .systemFont(ofSize: 17, weight: .regular)
        dayOfTheWeek.textColor = .black
        dayOfTheWeek.translatesAutoresizingMaskIntoConstraints = false
        
        return dayOfTheWeek
    }()
    
    private lazy var switcher: UISwitch = {
       let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.onTintColor = .ypBlue
        switcher.addTarget(self, action: #selector(swithcerDidTap), for: .touchUpInside)
        
        return switcher
    }()
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .ypBackground
        clipsToBounds = true
        
        contentView.addSubview(dayOfTheWeek)
        addSubview(switcher)
        
        NSLayoutConstraint.activate([
            dayOfTheWeek.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dayOfTheWeek.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Overrides Methods
    
    // MARK: - Public Methods
    @objc
    func swithcerDidTap() {
        self.selectedDay = switcher.isOn
    }
    
    func update(with title:String) {
        dayOfTheWeek.text = title
    }
}
