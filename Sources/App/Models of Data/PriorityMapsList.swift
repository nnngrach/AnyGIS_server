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
    var xMax: Double
    var xMin: Double
    var yMax: Double
    var yMin: Double
    
    
    init(id: Int? = nil, setName: String, zoomMin: Int, zoomMax: Int, priority: Int, mapName: String, notChecking: Bool, xMax: Double, xMin: Double, yMax: Double, yMin: Double) {
        self.setName = setName
        self.zoomMin = zoomMin
        self.zoomMax = zoomMax
        self.priority = priority
        self.mapName = mapName
        self.notChecking = notChecking
        self.xMax = xMax
        self.xMin = xMin
        self.yMax = yMax
        self.yMin = yMin
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension PriorityMapsList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension PriorityMapsList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension PriorityMapsList: Parameter { }
