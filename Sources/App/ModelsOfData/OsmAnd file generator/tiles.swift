//
//  MapData.swift
//
//  Created by HR_book on 17/03/2019.
//

import FluentSQLite
import Vapor


final class tiles: SQLiteModel {
    
    var id: Int?
    var x: Int?
    var y: Int?
    var z: Int?
    var s: Int?
    var image: Data?
    
    init(id: Int? = nil, x: Int? = nil, y: Int? = nil, z: Int? = nil, s: Int? = nil, image: Data? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.s = s
        self.image = image
    }
}

/// Allows `OsmandInfo` to be used as a dynamic migration.
extension tiles: Migration { }

/// Allows `OsmandInfo` to be encoded to and decoded from HTTP messages.
extension tiles: Content { }

/// Allows `OsmandInfo` to be used as a dynamic parameter in route definitions.
extension tiles: Parameter { }
