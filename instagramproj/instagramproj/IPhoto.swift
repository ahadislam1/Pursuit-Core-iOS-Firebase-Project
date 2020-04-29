//
//  IPhoto.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/29/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import Foundation

struct IPhoto: Codable {
    let id: String
    let imageURL: String
    let createdAt: Date
    let madeBy: String
}
