//
//  instagramprojTests.swift
//  instagramprojTests
//
//  Created by Ahad Islam on 4/28/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import XCTest
import FirebaseAuth
import Combine
@testable import instagramproj

class instagramprojTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()

    func testSignOut() {
        
        do {
            try Auth.auth().signOut()
            XCTAssert(Auth.auth().currentUser == nil)
        } catch {
            XCTFail("Failed: \(error.localizedDescription)")
        }
    }
    
    func testLoadPhotos() {
        let exp = XCTestExpectation()
        FirestoreService.shared.loadPhotos()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: { _ in
                exp.fulfill()
            })
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2)
    }
    
    func testImage() {
        let imageView = UIImageView()
        let exp = XCTestExpectation(description: "exp")
        FirestoreService.shared.loadPhotos()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail(error.localizedDescription)
                }}, receiveValue: { photos in
                    guard let photo = photos.first, let url = URL(string: photo.imageURL) else {
                        XCTFail("failed to get object")
                        return
                    }
                    imageView.setImage(url: url, in: &self.subscriptions)
                    exp.fulfill()
            })
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 3)
    }

}
