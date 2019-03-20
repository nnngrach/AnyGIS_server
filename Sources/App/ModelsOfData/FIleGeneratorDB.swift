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
    var groupNameEng: String           // Folders name, icon name.
    var shortName: String           // Short map name to show in app.
    var shortNameEng: String           // Short map name to show in app.
    
    var groupPrefix: String         // ../groupPrefix_clientMapName.xml
    var clientMapName: String
    var oruxGroupPrefix: String     // One word with CAPSLOCK
    
    var layersIDList: String        // "100, 101, 102".  First is background layer.
    
    var isInStarterSet: Bool        // This map is included in list of best maps.
    
    var projection: Int             // Locus map projection
   
    var countries: String           // Locus tags
    var usage: String
    
    var visible: Bool               // Locus tag for background layers
    
    var forLocus: Bool              // Use this record for generating Locus map file
    var forGuru: Bool               // Use this record for generating Guru map file
    var forOrux: Bool
    var forOsmand: Bool
    
    var locusLoadAnygis: Bool       // For comlicated maps, which no way
    var gurumapsLoadAnygis: Bool    // to realise in client map file.
    var oruxLoadAnygis: Bool
    var osmandLoadAnygis: Bool
    
    var cacheStoringHours: Int      // How much time in hours can be stored tile in cache
                                    // 0 = don't caching,  99999 = don't update
    
    var comment: String             // Second description for some maps
    
    var order: Int                  // Order to showing in Web page
    
    
    
    
    
    
    init(id: Int? = nil, anygisMapName: String, groupName: String, groupNameEng: String, shortName: String, shortNameEng: String, groupPrefix: String, oruxGroupPrefix: String, clientMapName: String, layersIDList: String, locusLoadAnygis: Bool, gurumapsLoadAnygis: Bool, oruxLoadAnygis: Bool, osmandLoadAnygis: Bool, isInStarterSet: Bool, projection: Int, visible: Bool, countries: String, usage: String, forLocus: Bool, forGuru: Bool, forOrux: Bool, forOsmand: Bool, cacheStoringHours: Int, comment: String, order: Int) {
        
        self.anygisMapName = anygisMapName
        self.groupName = groupName
        self.groupNameEng = groupNameEng
        self.shortName = shortName
        self.shortNameEng = shortNameEng
        self.groupPrefix = groupPrefix
        self.oruxGroupPrefix = oruxGroupPrefix
        self.clientMapName = clientMapName
        self.layersIDList = layersIDList
        self.locusLoadAnygis = locusLoadAnygis
        self.gurumapsLoadAnygis = gurumapsLoadAnygis
        self.oruxLoadAnygis = oruxLoadAnygis
        self.osmandLoadAnygis = osmandLoadAnygis
        self.isInStarterSet = isInStarterSet
        self.projection = projection
        self.visible = visible
        self.countries = countries
        self.usage = usage
        self.forLocus = forLocus
        self.forGuru = forGuru
        self.forOrux = forOrux
        self.forOsmand = forOsmand
        self.cacheStoringHours = cacheStoringHours
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
