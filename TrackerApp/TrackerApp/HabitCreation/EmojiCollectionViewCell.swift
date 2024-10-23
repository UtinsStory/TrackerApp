//
//  EmojiCollectionViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 23.10.2024.
//
import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionViewCell"
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        layer.cornerRadius = 16
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectEmoji() {
        contentView.backgroundColor = .ypLightGray
        contentView.layer.cornerRadius = 16
    }
    
    private func delesectEmoji() {
        contentView.backgroundColor = .clear
    }
}
