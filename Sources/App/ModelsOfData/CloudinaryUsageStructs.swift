//
//  CloudinaryUsageStructs.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 27/04/2019.
//

import Foundation

struct CloudinaryUsage: Codable {
    var plan: String
    var last_updated: String
    var transformations: CloudinaryTransformations
    var objects: CloudinaryObjects
    var bandwidth: CloudinaryBandwidth
    var storage: CloudinaryStorage
    var credits: CloudinaryCredits
    var requests: Int
    var resources: Int
    var derived_resources: Int
    var media_limits: CloudinaryLimits
}



struct CloudinaryTransformations: Codable {
    var usage: Int
    var credits_usage: Double
}

struct CloudinaryObjects: Codable {
    var usage: Int
}

struct CloudinaryBandwidth: Codable {
    var usage: Int
    var credits_usage: Double
}

struct CloudinaryStorage: Codable {
    var usage: Int
    var credits_usage: Double
}

struct CloudinaryCredits: Codable {
    var usage: Double
    var limit: Int
    var used_percent: Double
}

struct CloudinaryLimits: Codable {
    var image_max_size_bytes: Int
    var video_max_size_bytes: Int
    var raw_max_size_bytes: Int
    var image_max_px: Int
    var asset_max_total_px: Int
}
