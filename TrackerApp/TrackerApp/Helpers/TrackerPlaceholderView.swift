//
//  TrackerPlaceholderView.swift
//  TrackerApp
//
//  Created by Гена Утин on 21.10.2024.
//
import UIKit

final class PlaceholderView: UIView {
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = .ypBlack
        emptyStateLabel.textAlignment = .center
        
        return emptyStateLabel
    }()
    
    private lazy var emptyStateImageView = {
        let image = UIImageView(image: UIImage(named: "empty"))
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        setupEmptyState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func addElements() {
        [emptyStateLabel,
         emptyStateImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupEmptyState() {
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateImageView.bottomAnchor.constraint(equalTo: emptyStateLabel.topAnchor, constant: -8),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
