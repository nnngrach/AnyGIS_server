//
//  MapData.swift
//
//  Created by Nnngrach on 25/11/2018.
//

import FluentSQLite
import Vapor


final class MapsList: SQLiteModel {
    
    var id: Int?
    var name: String
    var mode: String
    var backgroundUrl: String
    var backgroundServerName: String
    var referer: String
    var zoomMin: Int
    var zoomMax: Int
    var dpiSD: String
    var dpiHD: String
    var parameters: Double
    var description: String
    
    init(id: Int? = nil, name: String, mode: String, backgroundUrl: String, backgroundServerName: String, referer: String, zoomMin: Int, zoomMax: Int, dpiSD: String, dpiHD: String, parameters: Double, description: String) {
        self.name = name
        self.mode = mode
        self.backgroundUrl = backgroundUrl
        self.backgroundServerName = backgroundServerName
        self.referer = referer
        self.zoomMin = zoomMin
        self.zoomMax = zoomMax
        self.dpiSD = dpiSD
        self.dpiHD = dpiHD
        self.parameters = parameters
        self.description = description
    }
}

/// Allows `MapData` to be used as a dynamic migration.
extension MapsList: Migration { }

/// Allows `MapData` to be encoded to and decoded from HTTP messages.
extension MapsList: Content { }

/// Allows `MapData` to be used as a dynamic parameter in route definitions.
extension MapsList: Parameter { }
