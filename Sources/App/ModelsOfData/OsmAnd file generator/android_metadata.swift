//
//  MapData.swift
//
//  Created by Nnngrach on 17/03/2019.
//

import FluentSQLite
import Vapor


final class android_metadata: SQLiteModel {
    
    var id: Int?
    var locale: String?
    
    init(id: Int? = nil, locale: String? = nil) {
        self.locale = locale
    }
}

/// Allows `OsmandInfo` to be used as a dynamic migration.
extension android_metadata: Migration { }

/// Allows `OsmandInfo` to be encoded to and decoded from HTTP messages.
extension android_metadata: Content { }

/// Allows `OsmandInfo` to be used as a dynamic parameter in route definitions.
extension android_metadata: Parameter { }
