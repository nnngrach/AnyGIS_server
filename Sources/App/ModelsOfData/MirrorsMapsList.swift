import FluentSQLite
import Vapor


final class MirrorsMapsList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var url: String
    var host: String
    var port: String
    var patch: String
    var isHttps: Bool
    
    init(id: Int? = nil, setName: String, url: String, host: String, port: String,patch: String, isHttps: Bool) {
        self.setName = setName
        self.url = url
        self.host = host
        self.port = port
        self.patch = patch
        self.isHttps = isHttps
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension MirrorsMapsList: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension MirrorsMapsList: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension MirrorsMapsList: Parameter { }
