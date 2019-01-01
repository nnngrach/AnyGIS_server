import FluentSQLite
import Vapor



//SQLiteModel
final class MirrorsMapsList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var url: String
    
    init(id: Int? = nil, setName: String, url: String) {
        self.setName = setName
        self.url = url
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension MirrorsMapsList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension MirrorsMapsList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension MirrorsMapsList: Parameter { }
