//
//  StravaStructs.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 13/04/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Foundation
import Vapor

struct StravaLoginRequest: Content {
    var email: String
    var password: String
}

struct StravaOutputJson: Codable {
    var name: String
    var value: String
}
