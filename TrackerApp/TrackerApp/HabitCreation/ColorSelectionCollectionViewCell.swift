//
//  ColorSelectionCollectionViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 23.10.2024.
//
import UIKit

final class ColorSelectionCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorSelectionCollectionViewCell"
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -6),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectColor() {
        layer.borderWidth = 3
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 8
    }
    
    func deselectColor() {
        layer.borderWidth = 0
    }
    
    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }
    
}
