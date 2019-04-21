//
//  HerokuStorage.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 21/04/2019.
//

import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class HerokuStorage: SQLiteModel {
    
    /// The unique identifier for this `Storage`.
    var id: Int?
    
    /// A title describing what this `Storage` entails.
    var title: String
    
    /// Timestamp of current record
    var unixTime: Int
    
    /// Stored data in JSON format
    var data: String
    
    
    /// Creates a new `Todo`.
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

