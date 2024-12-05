//
//  TrackersCollectionViewCell.swift
//  TrackerApp
//
//  Created by Гена Утин on 06.10.2024.
//
import UIKit

protocol TrackersCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "TrackerCell"
    
    var onPin: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var isPinned: Bool = false {
        didSet {
            pinIconView.isHidden = !isPinned
            pinActionTitle = isPinned ? LocalizationHelper.localizedString("unpin") : LocalizationHelper.localizedString("pin")
        }
    }
    
    private var pinActionTitle = LocalizationHelper.localizedString("pin")
    
    var daysCounter = 0
    
    let coloredRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypColorSelection1
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "🍏"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pinIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let whiteEmojiBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Выпить пива после пробежки"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        return label
    }()
    
    let nonColoredRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "\(daysCounter)"
        return label
    }()
    
    private lazy var coloredCircleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal) // ?
        button.backgroundColor = .ypColorSelection1
        let image = UIImage(named: "plus")?
            .withTintColor(UIColor(ciColor: .white), renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(coloredCircleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TrackersCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Нет инициализации")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coloredRectangleView.layer.cornerRadius = 16
        coloredRectangleView.layer.masksToBounds = true
        
        whiteEmojiBackground.layer.cornerRadius = 12
        whiteEmojiBackground.clipsToBounds = true
        
        coloredCircleButton.layer.cornerRadius = 17
        coloredCircleButton.clipsToBounds = true
    }
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        coloredRectangleView.addInteraction(interaction)
    }
    //MARK: - Helpers
    
    private func setupUI() {
        contentView.addSubview(coloredRectangleView)
        coloredRectangleView.addSubview(emojiLabel)
        coloredRectangleView.addSubview(whiteEmojiBackground)
        coloredRectangleView.addSubview(mainLabel)
        coloredRectangleView.addSubview(pinIconView)
        contentView.addSubview(nonColoredRectangleView)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(coloredCircleButton)
        
        NSLayoutConstraint.activate([
            coloredRectangleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredRectangleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredRectangleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredRectangleView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.centerXAnchor.constraint(equalTo: whiteEmojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: whiteEmojiBackground.centerYAnchor),
            
            whiteEmojiBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            whiteEmojiBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            whiteEmojiBackground.widthAnchor.constraint(equalToConstant: 24),
            whiteEmojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            mainLabel.leadingAnchor.constraint(equalTo: coloredRectangleView.leadingAnchor, constant: 12),
            mainLabel.trailingAnchor.constraint(equalTo: coloredRectangleView.trailingAnchor, constant: -12),
            mainLabel.heightAnchor.constraint(equalToConstant: 34),
            mainLabel.bottomAnchor.constraint(equalTo: coloredRectangleView.bottomAnchor, constant: -12),
            
            nonColoredRectangleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nonColoredRectangleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nonColoredRectangleView.topAnchor.constraint(equalTo: coloredRectangleView.bottomAnchor),
            nonColoredRectangleView.heightAnchor.constraint(equalToConstant: 58),
            
            coloredCircleButton.trailingAnchor.constraint(equalTo: nonColoredRectangleView.trailingAnchor, constant: -12),
            coloredCircleButton.bottomAnchor.constraint(equalTo: nonColoredRectangleView.bottomAnchor, constant: -16),
            coloredCircleButton.widthAnchor.constraint(equalToConstant: 34),
            coloredCircleButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: coloredCircleButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: nonColoredRectangleView.leadingAnchor, constant: 12),
            
            pinIconView.topAnchor.constraint(equalTo: coloredRectangleView.topAnchor, constant: 12),
            pinIconView.trailingAnchor.constraint(equalTo: coloredRectangleView.trailingAnchor, constant: -4),
            pinIconView.widthAnchor.constraint(equalToConstant: 24),
            pinIconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath,
        isPinned: Bool
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        self.isPinned = isPinned
        
        mainLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        
        if let color = UIColor(hexString: tracker.color) {
            coloredRectangleView.backgroundColor = color
            coloredCircleButton.backgroundColor = color
        }
        
        let wordDay = pluralizeDays(completedDays)
        daysCounterLabel.text = wordDay
        
        let image = isCompletedToday ? doneImage : plusImage
        coloredCircleButton.setImage(image, for: .normal)
        
        let alphaValue: CGFloat = isCompletedToday ? 0.3 : 1.0
        coloredCircleButton.backgroundColor = coloredCircleButton.backgroundColor?.withAlphaComponent(alphaValue)
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) \(LocalizationHelper.localizedString("day"))"
        } else if remainder10 >= 2 && remainder100 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) \(LocalizationHelper.localizedString("days"))"
        } else {
            return "\(count) \(LocalizationHelper.localizedString("days"))"
        }
    }
    
    private let plusImage: UIImage = {
        let image = UIImage(named: "plus")?.withTintColor(UIColor.ypWhite) ?? UIImage()
        return image
    }()
    
    private let doneImage: UIImage = {
        let image = UIImage(named: "tracker_done")?.withTintColor(UIColor.ypWhite) ?? UIImage()
        return image
    }()
    
    @objc private func coloredCircleButtonTapped() {
        
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("Tracker ID not found")
            return
        }
        
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension TrackersCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            guard let self = self else { return nil }
            
            let pinAction = UIAction(title: self.pinActionTitle) { [weak self] action in
                self?.onPin?()
            }
            
            let editAction = UIAction(title: LocalizationHelper.localizedString("edit")) { [weak self] action in
                self?.onEdit?()
            }
            
            let deleteAction = UIAction(title: LocalizationHelper.localizedString("delete"), attributes: .destructive) { [weak self] action in
                self?.onDelete?()
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
