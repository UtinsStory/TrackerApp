//
//  UIView+Extension.swift
//  TrackerApp
//
//  Created by Гена Утин on 08.10.2024.
//
import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
