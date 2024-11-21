//
//  TrackerFilterPlaceholder.swift
//  TrackerApp
//
//  Created by Гена Утин on 21.10.2024.
//
import UIKit

final class PlaceholderNoFilterResultsView: UIView {
    
    private func setNoResult() {
 
        let noResultsLabel = UILabel()
        noResultsLabel.text = LocalizationHelper.localizedString("nothingFound")
        noResultsLabel.textColor = .ypBlack
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(noResultsLabel)
  
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
 
        let noResultsImageView = UIImageView(image: UIImage(named: "empty_search"))
        noResultsImageView.contentMode = .scaleAspectFit
        noResultsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(noResultsImageView)
        
        NSLayoutConstraint.activate([
            noResultsImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsImageView.bottomAnchor.constraint(equalTo: noResultsLabel.topAnchor, constant: -8),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 80), 
            noResultsImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
