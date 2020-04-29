//
//  AuthService.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthError: Error {
    case noUser
    
    var localizedDescription: String {
        switch self {
        case .noUser:
            return "No user currently logged into the system."
        }
    }
}

class AuthService {
    public static let shared = AuthService()
    
    private let auth = Auth.auth()
    
    private init() {}
    
    public func loginUser(email: String, password: String) -> Future<Void, Error> {
        
        Future<Void, Error> { promise in
            self.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let _ = result {
                    promise(.success(()))
                }
            }
        }
    }
    
    public func createUser(email: String, password: String) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            self.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let _ = result {
                    promise(.success(()))
                }
            }
        }
    }
    
    public func updateUser(_ name: String? = nil, photoURL: URL? = nil) -> Future<Void, Error> {
        Future<Void,Error> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(AuthError.noUser))
                return
            }
            let request = user.createProfileChangeRequest()
            if let name = name {
                request.displayName = name
            }
            if let photoURL = photoURL {
                request.photoURL = photoURL
            }
            request.commitChanges { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
}
