//
//  FirestoreService.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


class FirestoreService {
    
    public static let shared = FirestoreService()
    
    private static let photoCollections = "photos"
    
    private let db = Firestore.firestore()

    private init() {}
    
    public func createPhoto(photo: IPhoto) -> Future<Void, Error> {
        let doc = db.collection(FirestoreService.photoCollections).document(photo.id)
                
        return Future<Void, Error> { promise in
            do {
                try doc.setData(from: photo)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    public func loadPhotos() -> Future<[IPhoto], Error> {
        let docs = db.collection(FirestoreService.photoCollections)
        
        return Future<[IPhoto], Error> { promise in
            docs.getDocuments { (snapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let snapshot = snapshot {
                    let posts = snapshot.documents.compactMap { try? $0.data(as: IPhoto.self)}
                    promise(.success(posts))
                }
            }
        }
    }
    
    public func listener(completion: @escaping(Result<[IPhoto], Error>) -> ())  {
        let docs = db.collection(FirestoreService.photoCollections)
        
        docs.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let photos = snapshot.documents.compactMap {
                    try? $0.data(as: IPhoto.self)
                }
                completion(.success(photos))
            }
        }
        
    }
    
}
