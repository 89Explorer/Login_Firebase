//
//  AuthService.swift
//  Login_Firebase
//
//  Created by 권정근 on 12/3/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AutheService {
    
    public static let shared = AutheService()
    private init() { }
    
    /*
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
     */
    

    func registerUser(request: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        // 1. Firebase Auth로 사용자 생성
        Auth.auth().createUser(withEmail: request.email, password: request.password) { authResult, error in
            if let error = error {
                print("Firebase Auth 사용자 생성 실패: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let userUID = authResult?.user.uid else {
                let uidError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 UID를 가져올 수 없습니다."])
                completion(false, uidError)
                return
            }
            
            // 2. 이미지 업로드와 Firestore 데이터 저장 통합
            self.uploadProfileAndSaveUserToFirestore(userUID: userUID, request: request) { success, error in
                if success {
                    print("회원가입 성공")
                    completion(true, nil)
                } else {
                    print("회원가입 실패: \(error?.localizedDescription ?? "알 수 없는 에러")")
                    completion(false, error)
                }
            }
        }
    }

    private func uploadProfileAndSaveUserToFirestore(userUID: String, request: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        // 1. 이미지를 Firebase Storage에 업로드
        guard let imageData = request.userImage.jpegData(compressionQuality: 0.5) else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 변환할 수 없습니다."]))
            return
        }
        
        let storageRef =
        Storage.storage().reference().child("profile_images/\(userUID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Firebase Storage 업로드 실패: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            // 2. 다운로드 URL 가져오기
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Firebase Storage 다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                guard let profileImageURL = url?.absoluteString else {
                    completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 URL을 가져올 수 없습니다."]))
                    return
                }
                
                // 3. Firestore에 사용자 정보 저장
                self.saveUserToFirestore(userUID: userUID, username: request.username, email: request.email, profileImageURL: profileImageURL) { success, error in
                    completion(success, error)
                }
            }
        }
    }

    private func saveUserToFirestore(userUID: String, username: String, email: String, profileImageURL: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "profileImageURL": profileImageURL,
            "createdAt": Timestamp()
        ]
        
        db.collection("users").document(userUID).setData(userData) { error in
            if let error = error {
                print("Firestore 저장 실패: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Firestore 저장 성공")
                completion(true, nil)
            }
        }
    }

    
    
    
    public func signIn(with userRequest: LoginUserRequest,
                       completion: @escaping (Error?) -> Void) {
        
        let email = userRequest.email
        let password = userRequest.password
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            } else {
                completion(nil)
            }
        }
    }
    
    public func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    
    public func forgotPassword(with email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    /*
    public func fetchUser(completion: @escaping (User?, Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."]))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshotData = snapshot?.data(),
                  let username = snapshotData["username"] as? String,
                  let email = snapshotData["email"] as? String else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore 데이터가 올바르지 않습니다."]))
                return
            }
            
            let pathRef = Storage.storage().reference(withPath: "profile_images/\(userUID).jpg")
            
            pathRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                let userImage: UIImage = {
                    if let data = data, let image = UIImage(data: data) {
                        return image
                    } else {
                        print("이미지를 가져오지 못했습니다: \(error?.localizedDescription ?? "알 수 없는 에러")")
                        return UIImage(named: "default_profile")!
                    }
                }()
                
                let user = User(username: username, email: email, userUID: userUID, userImage: userImage)
                completion(user, nil)
            }
        }
    }
    */

    
    
    
    public func fetchUser(completion: @escaping (User?, Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."]))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshotData = snapshot?.data(),
                  let username = snapshotData["username"] as? String,
                  let email = snapshotData["email"] as? String else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore 데이터가 올바르지 않습니다."]))
                return
            }
            
            let pathRef = Storage.storage().reference(withPath: "profile_images/\(userUID).jpg")
            
            // Firebase Storage에서 URL 가져오기
            pathRef.downloadURL { url, error in
                if let error = error {
                    print("Firebase Storage 다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                let profileImageURL = url?.absoluteString
                print("Firebase Storage에서 다운로드 URL: \(profileImageURL ?? "없음")")
                
                // User 객체 생성 (URL 사용)
                let user = User(username: username, email: email, userUID: userUID, userImage: profileImageURL!)
                completion(user, nil)
            }
        }
    }
    
    
    
    
    public func deleteUser(completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."]))
            return
        }
        
        let db = Firestore.firestore()
        let userUID = user.uid
        
        // Firestore 데이터 삭제
        db.collection("users").document(userUID).delete { error in
            if let error = error {
                completion(false, error)
                return
            }
            
            // Firebase Authentication 사용자 삭제
            user.delete { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                completion(true, nil) // 성공
            }
        }
    }
}
