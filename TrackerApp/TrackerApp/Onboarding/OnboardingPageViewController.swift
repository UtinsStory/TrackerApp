//
//  OnboardingPageViewController.swift
//  TrackerApp
//
//  Created by Гена Утин on 13.11.2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = OnboardingPage.allCases.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypGray
        pageControl.pageIndicatorTintColor = .ypBlack
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    lazy var continueButton: UIButton = {
        let continueButton = UIButton(type: .system)
        continueButton.setTitle(LocalizationHelper.localizedString("onboardingButtonText"), for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        continueButton.setTitleColor(.ypWhite, for: .normal)
        
        continueButton.backgroundColor = .black
        continueButton.layer.cornerRadius = 16
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        continueButton.addTarget(self, action: #selector(continueButtonDidTap), for: .touchUpInside)
        
        return continueButton
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        view.addSubviews([pageControl, continueButton])
        
        NSLayoutConstraint.activate([
            
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        if let firstPage = viewController(for: .pageOne) {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func viewController(for page: OnboardingPage) -> UIViewController? {
        
        return OnboardingViewController(page: page)
    }
    
    private func switchToMainScreen() {
        if let window = view?.window {
            let mainScreen = TabBarController()
            window.rootViewController = mainScreen
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    @objc private func continueButtonDidTap() {
        UserDefaults.standard.set(true, forKey: "OnboardingIsCompleted")
        switchToMainScreen()
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue - 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue + 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleController = pageViewController.viewControllers?.first as? OnboardingViewController {
            pageControl.currentPage = visibleController.page.rawValue
        }
    }
}

enum OnboardingPage: Int, CaseIterable {
    case pageOne = 0
    case pageTwo
    
    var title: String {
        switch self {
        case .pageOne:
            return LocalizationHelper.localizedString("onboardingText1")
        case .pageTwo:
            return LocalizationHelper.localizedString("onboardingText2")
        }
    }
    
    var image: String {
        switch self {
        case .pageOne:
            return "onboarding1"
        case .pageTwo:
            return "onboarding2"
        }
    }
}

