import FluentSQLite
import Vapor



//SQLiteModel
final class PriorityMapsList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var zoomMin: Int
    var zoomMax: Int
    var priority: Int
    var mapName: String
    var notChecking: Bool
    
    
    init(id: Int? = nil, setName: String, zoomMin: Int, zoomMax: Int, priority: Int, mapName: String, notChecking: Bool) {
        self.setName = setName
        self.zoomMin = zoomMin
        self.zoomMax = zoomMax
        self.priority = priority
        self.mapName = mapName
        self.notChecking = notChecking
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension PriorityMapsList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension PriorityMapsList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension PriorityMapsList: Parameter { }
