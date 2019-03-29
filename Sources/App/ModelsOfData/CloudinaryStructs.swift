//
//  CloudinaryStructs.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 15/12/2018.
//

import Vapor

struct CloudinaryPostMessage: Content {
    var file: String
    var public_id: String
    var upload_preset: String
}


struct CloudinarySesrchResponse: Content {
    let total_count: Int
}
