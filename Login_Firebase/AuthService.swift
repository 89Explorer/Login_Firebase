//
//  AuthService.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/3/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AutheService {
    
    public static let shared = AutheService()
    private init() { }
    
    
    /// A method to register the user
    /// - Parameters:
    ///   - userRequest: The users information (email, password, username)
    ///   - completion: A completion with two values...
    ///   - Bool: wasRegistered - Determines if the user was registered and saved in the database correctly
    ///   - Error?: An optional error if firebase provides once
    public func registerUser(with userRequest: RegisterUserRequest,
                             completion: @escaping (Bool, Error?) -> Void) {
        
        let username = userRequest.username
        let email = userRequest.email
        let password = userRequest.password
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let resultUser = result?.user else {
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            
            db.collection("users")
                .document(resultUser.uid)
                .setData([
                    "username": username,
                    "email": email
                ]) { error in
                    if let error = error {
                        completion(false, error)
                        return
                    }
                    
                    completion(true, nil)
                }
        }
    }
    
}
