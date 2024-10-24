//
//  EmojiCollectionViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 23.10.2024.
//
import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionViewCell"
    
    private lazy var emojisLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojisLabel)
        layer.cornerRadius = 16
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            emojisLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojisLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectEmoji() {
        contentView.backgroundColor = .ypLightGray
        contentView.layer.cornerRadius = 16
    }
    
    func deselectEmoji() {
        contentView.backgroundColor = .clear
    }
    
    func setEmoji(_ emoji: String) {
        emojisLabel.text = emoji
    }
}
