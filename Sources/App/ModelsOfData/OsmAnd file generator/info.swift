//
//  MapData.swift
//
//  Created by HR_book on 17/03/2019.
//

import FluentSQLite
import Vapor


final class info: SQLiteModel {
    
    var id: Int?
    var minzoom: Data?
    var maxzoom: Data?
    var url: Data?
    var tilenumbering: String?
    var timecolumn: String?
    var expireminutes: String?
    var ellipsoid: Int?
    var rule: String?
    
    
    
    init(id: Int? = nil, minzoom: Data? = nil, maxzoom: Data? = nil, url: Data? = nil, tilenumbering: String? = nil, timecolumn: String? = nil, expireminutes: String? = nil, ellipsoid: Int? = nil, rule: String? = nil) {
        self.minzoom = minzoom
        self.maxzoom = maxzoom
        self.url = url
        self.tilenumbering = tilenumbering
        self.timecolumn = timecolumn
        self.expireminutes = expireminutes
        self.ellipsoid = ellipsoid
        self.rule = rule
    }
}

/// Allows `OsmandInfo` to be used as a dynamic migration.
extension info: Migration { }

/// Allows `OsmandInfo` to be encoded to and decoded from HTTP messages.
extension info: Content { }

/// Allows `OsmandInfo` to be used as a dynamic parameter in route definitions.
extension info: Parameter { }
