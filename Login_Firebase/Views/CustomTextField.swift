//
//  CustomTextField.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/2/24.
//

import UIKit

class CustomTextField: UITextField {

    // MARK: - Enum
    enum CustomTextFieldType {
        case username
        case email
        case password
    }
    
    private let authFieldType: CustomTextFieldType
    
    init(fieldType: CustomTextFieldType) {
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .username:
            self.placeholder = "Username"
        case .email:
            self.placeholder = "Email"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.placeholder = "Password"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true 
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
