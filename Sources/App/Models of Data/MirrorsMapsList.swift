import FluentSQLite
import Vapor



//SQLiteModel
final class MirrorsMapsList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var url: String
    var host: String
    var patch: String
    
    init(id: Int? = nil, setName: String, url: String, host: String, patch: String) {
        self.setName = setName
        self.url = url
        self.host = host
        self.patch = patch
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension MirrorsMapsList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension MirrorsMapsList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension MirrorsMapsList: Parameter { }
