//
//  HerokuStorage.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 21/04/2019.
//

/// DEPRECATED!

import FluentSQLite
import Vapor

final class HerokuStorage: SQLiteModel {
    
    var id: Int?
    var title: String
    var unixTime: Int
    var data: String
    
    init(id: Int? = nil, title: String, unixTime: Int, data: String) {
        self.id = id
        self.title = title
        self.unixTime = unixTime
        self.data = data
    }
}


/// Allows `Storage` to be used as a dynamic migration.
extension HerokuStorage: Migration { }

/// Allows `Storage` to be encoded to and decoded from HTTP messages.
extension HerokuStorage: Content { }

/// Allows `Storage` to be used as a dynamic parameter in route definitions.
extension HerokuStorage: Parameter { }

