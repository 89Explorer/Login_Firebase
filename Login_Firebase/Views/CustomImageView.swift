//
//  CustomImageView.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/4/24.
//

import UIKit

class CustomImageView: UIImageView {

    enum ImageType {
        case system(String, pointSize: CGFloat)
        case user(UIImage)
    }
    
    private var imageType: ImageType? {
        didSet {
            updateImageAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureImageViewStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageViewStyle() {
        
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.black.cgColor
        self.backgroundColor = .white
        self.layer.cornerRadius = 50
        self.clipsToBounds = true
        
    }
    
    func setImageType(_ type: ImageType) {
        self.imageType = type
    }
    
    
    private func updateImageAppearance() {
        
        switch imageType {
        case .system(let systemName, let pointSize):
            let config = UIImage.SymbolConfiguration(pointSize: pointSize)
            self.image = UIImage(systemName: systemName, withConfiguration: config)
            self.tintColor = .black
            self.contentMode = .center
        case .user(let userImage):
            self.image = userImage
            self.contentMode = .scaleAspectFill
        case .none:
            self.image = nil
        }
    }
    
}
