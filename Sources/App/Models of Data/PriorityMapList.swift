import FluentSQLite
import Vapor



//SQLiteModel
final class PriorityMapList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var zoom: Int
    var priority: Int
    var mapName: String
    
    init(id: Int? = nil, setName: String, zoom: Int, priority: Int, mapName: String) {
        self.setName = setName
        self.zoom = zoom
        self.priority = priority
        self.mapName = mapName
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension PriorityMapList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension PriorityMapList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension PriorityMapList: Parameter { }

//extension PriorityMapList: Codable { }
