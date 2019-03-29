//
//  osmandDbExtention.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 24/03/2019.
//

import Vapor
import FluentSQLite

extension DatabaseIdentifier {
    
    public static var sqliteOsmand: DatabaseIdentifier<SQLiteDatabase> {
        return "sqliteOsmand"
    }
}
