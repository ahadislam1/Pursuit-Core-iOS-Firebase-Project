//
//  instagramprojTests.swift
//  instagramprojTests
//
//  Created by Ahad Islam on 4/28/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import XCTest
import FirebaseAuth
@testable import instagramproj

class instagramprojTests: XCTestCase {

    func testSignOut() {
        do {
            try Auth.auth().signOut()
            XCTAssert(0 == 0)
        } catch {
            XCTFail("Failed: \(error.localizedDescription)")
        }
    }

}
