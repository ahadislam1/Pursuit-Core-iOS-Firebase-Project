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
    
    public func createUser(email: String, password: String) {
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
}
