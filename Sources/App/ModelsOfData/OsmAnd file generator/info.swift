//
//  MapData.swift
//
//  Created by Nnngrach on 17/03/2019.
//

import FluentSQLite
import Vapor


final class info: SQLiteModel {
    
    var id: Int?
    var minzoom: String?
    var maxzoom: String?
    var url: String?
    var tilenumbering: String?
    var timecolumn: String?
    var expireminutes: String?
    var ellipsoid: Int?
    var rule: String?
    
    
    
    init(id: Int? = nil, minzoom: String? = nil, maxzoom: String? = nil, url: String? = nil, tilenumbering: String? = nil, timecolumn: String? = nil, expireminutes: String? = nil, ellipsoid: Int? = nil, rule: String? = nil) {
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
