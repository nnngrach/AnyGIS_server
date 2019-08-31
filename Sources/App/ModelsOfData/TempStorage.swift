//
//  TempBase.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 31/08/2019.
//

import FluentSQLite
import Vapor


final class TempStorage: SQLiteModel {
    
    var id: Int?
    var name: String
    var value: String
    
    
    init(id: Int? = nil, name: String, value: String) {
        self.name = name
        self.value = value
    }
}


extension TempStorage: Migration { }
extension TempStorage: Content { }
extension TempStorage: Parameter { }
