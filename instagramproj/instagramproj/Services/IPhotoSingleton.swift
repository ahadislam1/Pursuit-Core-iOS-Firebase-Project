//
//  IPhotoSingleton.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/30/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import Foundation
import Combine

class IPhotoSingleton {
    
    static let shared = IPhotoSingleton()
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published public var photos = [IPhoto]()
    
    private init() {}
    
    public func loadPhotos() throws {
        var photoError: Error? = nil
        
        FirestoreService.shared.listener { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    photoError = error
                }
            case .success(let photos):
                DispatchQueue.main.async {
                    self?.photos = photos
                }
            }
        }
        
        if let error = photoError {
            throw error
        }
    }
    
    
    
}
