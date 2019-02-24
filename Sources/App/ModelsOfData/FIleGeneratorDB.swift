//
//  MapData.swift
//
//  Created by HR_book on 25/11/2018.
//

import FluentSQLite
import Vapor


final class FileGeneratorDB: SQLiteModel {
    
    var id: Int?                    // Use here Locus ID values.
    var anygisMapName: String       // For fething for MapList database.
    
    var groupName: String           // Folders name, icon name.
    var groupPrefix: String         // ../groupPrefix_clientMapName.xml
    var clientMapName: String
    
    var layersIDList: String        // "100, 101, 102".  First is background layer.
    
    var locusLoadAnygis: Bool       // For comlicated maps, which no way
    var gurumapsLoadAnygis: Bool    // to realise in client map file.
    
    var isInStarterSet: Bool        // This map is included in list of best maps.
    
    
    init(id: Int? = nil, anygisMapName: String, groupName: String, groupPrefix: String, clientMapName: String, layersIDList: String, locusLoadAnygis: Bool, gurumapsLoadAnygis: Bool, isInStarterSet: Bool) {
        self.anygisMapName = anygisMapName
        self.groupName = groupName
        self.groupPrefix = groupPrefix
        self.clientMapName = clientMapName
        self.layersIDList = layersIDList
        self.locusLoadAnygis = locusLoadAnygis
        self.gurumapsLoadAnygis = gurumapsLoadAnygis
        self.isInStarterSet = isInStarterSet
    }
}

/// Allows this database to be used as a dynamic migration.
extension FileGeneratorDB: Migration { }

/// Allows this database to be encoded to and decoded from HTTP messages.
extension FileGeneratorDB: Content { }

/// Allows this database to be used as a dynamic parameter in route definitions.
extension FileGeneratorDB: Parameter { }
