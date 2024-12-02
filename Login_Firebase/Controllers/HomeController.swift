//
//  HomeController.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/2/24.
//

import UIKit

class HomeController: UIViewController {

    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.text = "Loading...."
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Constraints
    private func configureConstraints() {
        self.view.backgroundColor = .systemBrown
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
    }
    
    // MARK: - Selectors
    @objc private func didTapLogout() {
        
    }
}

