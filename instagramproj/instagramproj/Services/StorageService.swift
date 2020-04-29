//
//  StorageService.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseAuth

enum Experience {
    case user
    case photo
}

class StorageService {
    
    static let shared = StorageService()
    
    private let storageRef = Storage.storage().reference()
    private init() {}
    
    public func uploadPhoto(id: String, imageURL: URL, exp: Experience) -> Future<URL, Error> {
        
        var photoReference: StorageReference!
        
        switch exp {
        case .photo:
            photoReference = storageRef.child("Photos/\(id).jpeg")
        case .user:
            photoReference = storageRef.child("UserProfilePhotos/\(id).jpeg")
        }
        
        return Future<URL, Error> { promise in
            let _ = photoReference.putFile(from: imageURL, metadata: nil) { _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    photoReference.downloadURL { (url, error) in
                        if let error = error {
                            promise(.failure(error))
                        } else if let url = url {
                            promise(.success(url))
                        }
                    }
                }
            }
        }
    }
    
}
