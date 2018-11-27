//
//  MapData.swift
//
//  Created by HR_book on 25/11/2018.
//

import FluentSQLite
import Vapor



//SQLiteModel
final class MapData: SQLiteModel {
    
    var id: Int?
    
    var name: String
    var mode: String
    
    var backgroundUrl: String
    var backgroundServerName: String
    var overlayUrl: String
    var overlayServerName: String
    
    var zoomMin: Int
    var zoomMax: Int
    
    var description: String

    
    init(id: Int? = nil, name: String, mode: String, backgroundUrl: String, backgroundServerName: String, overlayUrl: String, overlayServerName: String, zoomMin: Int, zoomMax: Int, description: String) {
        self.name = name
        self.mode = mode
        self.backgroundUrl = backgroundUrl
        self.backgroundServerName = backgroundServerName
        self.overlayUrl = overlayUrl
        self.overlayServerName = overlayServerName
        self.zoomMin = zoomMin
        self.zoomMax = zoomMax
        self.description = description
    }
}


/// Allows `MapData` to be used as a dynamic migration.
extension MapData: Migration { }

/// Allows `MapData` to be encoded to and decoded from HTTP messages.
extension MapData: Content { }

/// Allows `MapData` to be used as a dynamic parameter in route definitions.
extension MapData: Parameter { }

//extension MapData: Codable { }
