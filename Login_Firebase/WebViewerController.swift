//
//  WebViewerController.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/3/24.
//

import UIKit
import WebKit

class WebViewerController: UIViewController {

    // MARK: - Variables
    private let urlString: String
    
    // MARK: - UI Components
    private let webView = WKWebView()
    
    
    // MARK: - Initializations
    init(with urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()

        guard let url = URL(string: self.urlString) else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.webView.load(URLRequest(url: url))
    }
    
    // MARK: - Constraints
    private func configureConstraints() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        self.navigationController?.navigationBar.backgroundColor = .secondarySystemBackground
        
        
        self.view.addSubview(webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    // MARK: - Selectors
    @objc private func didTapDone() {
        self.dismiss(animated: true, completion: nil)
    }
}
