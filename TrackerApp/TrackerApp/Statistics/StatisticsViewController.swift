//
//  StatisticsViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 27.09.2024.
//
import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var completedTrackerCount: Int = 0
    
    private lazy var statisticsItemView: StatisticsItemView = {
        let view = StatisticsItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(value: 0, description: LocalizationHelper.localizedString("completedTrackers"))
        return view
    }()
    
    private let emptyStatisticLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("emptyStatisticText")
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "empty_search2"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
        
        CoreDataMain.shared.trackerRecordStore.delegate = self
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = LocalizationHelper.localizedString("statistic")
        
        view.addSubview(emptyStatisticLabel)
        view.addSubview(errorImageView)
        view.addSubview(statisticsItemView)
        
        NSLayoutConstraint.activate([
            emptyStatisticLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatisticLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorImageView.bottomAnchor.constraint(equalTo: emptyStatisticLabel.topAnchor, constant: -8),
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            
            statisticsItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            statisticsItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsItemView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func updateUI() {
        completedTrackerCount = CoreDataMain.shared.trackerRecordStore.getCompletedTrackersCount()
        
        statisticsItemView.configure(value: completedTrackerCount, description: LocalizationHelper.localizedString("completedTrackers"))
        
        let isEmpty = completedTrackerCount == 0
        
        emptyStatisticLabel.isHidden = !isEmpty
        errorImageView.isHidden = !isEmpty
        statisticsItemView.isHidden = isEmpty
        
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    
    func trackerRecordStoreDidUpdate() {
        updateUI()
    }
}
