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
    var shortName: String           // Short map name to show in app.
    var groupPrefix: String         // ../groupPrefix_clientMapName.xml
    var clientMapName: String
    
    var layersIDList: String        // "100, 101, 102".  First is background layer.
    
    var locusLoadAnygis: Bool       // For comlicated maps, which no way
    var gurumapsLoadAnygis: Bool    // to realise in client map file.
    
    var isInStarterSet: Bool        // This map is included in list of best maps.
    
    var projection: Int             // Locus map projection
   
    var countries: String           // Locus tags
    var usage: String
    
    var visible: Bool               // Locus tag for background layers
    
    var forLocus: Bool              // Use this record for generating Locus map file
    var forGuru: Bool               // Use this record for generating Guru map file
    
    var comment: String             // Second description for some maps
    
    var order: Int                  // Order to showing in Web page
    
    
    
    
    
    
    init(id: Int? = nil, anygisMapName: String, groupName: String, shortName: String, groupPrefix: String, clientMapName: String, layersIDList: String, locusLoadAnygis: Bool, gurumapsLoadAnygis: Bool, isInStarterSet: Bool, projection: Int, visible: Bool, countries: String, usage: String, forLocus: Bool, forGuru: Bool, comment: String, order: Int) {
        
        self.anygisMapName = anygisMapName
        self.groupName = groupName
        self.shortName = shortName
        self.groupPrefix = groupPrefix
        self.clientMapName = clientMapName
        self.layersIDList = layersIDList
        self.locusLoadAnygis = locusLoadAnygis
        self.gurumapsLoadAnygis = gurumapsLoadAnygis
        self.isInStarterSet = isInStarterSet
        self.projection = projection
        self.visible = visible
        self.countries = countries
        self.usage = usage
        self.forLocus = forLocus
        self.forGuru = forGuru
        self.comment = comment
        self.order = order
    }
}

/// Allows this database to be used as a dynamic migration.
extension FileGeneratorDB: Migration { }

/// Allows this database to be encoded to and decoded from HTTP messages.
extension FileGeneratorDB: Content { }

/// Allows this database to be used as a dynamic parameter in route definitions.
extension FileGeneratorDB: Parameter { }
