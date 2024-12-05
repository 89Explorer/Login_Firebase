//
//  HomeController.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/2/24.
//

import UIKit
import SDWebImage

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
    
    private let profileImage = CustomImageView(frame: .zero)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraints()
        self.profileImage.setImageType(.system("person", pointSize: 25))
        
        AutheService.shared.fetchUser { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showFetchingUserError(on: self, with: error)
                return
            }
            
            if let user = user {
                DispatchQueue.main.async {
                    self.label.text = "Username : \(user.username) \n UserEmail : \(user.email)"
                    if let profileImageURL = user.userImage,
                       let url = URL(string: profileImageURL) {
                        self.profileImage.setImageType(.user(.url(url)))
                    } else {
                        self.profileImage.setImageType(.user(.image(UIImage(named: "profile")!)))
                    }
                }
                
            }
        }
    }
    
    // MARK: - Constraints
    private func configureConstraints() {
        self.view.backgroundColor = .systemBrown
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        let deleteUserButton = UIBarButtonItem(title: "DeleteUser", style: .plain, target: self, action: #selector(didTapDelete))
        self.navigationItem.rightBarButtonItems = [deleteUserButton, logoutButton]
        
        self.view.addSubview(label)
        self.view.addSubview(profileImage)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            profileImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            profileImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    // MARK: - Selectors
    @objc private func didTapLogout() {
        AutheService.shared.signOut { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showLogoutErrorAlert(on: self, with: error)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
        }
    }
    
    @objc private func didTapDelete() {
        AutheService.shared.deleteUser { success, error in
            if success {
                print("회원 탈퇴 성공!")
                // 탈퇴 후 초기 화면으로 이동
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            } else if let error = error {
                print("회원 탈퇴 실패: \(error.localizedDescription)")
            }
        }

    }
}

