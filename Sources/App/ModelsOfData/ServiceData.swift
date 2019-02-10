import FluentSQLite
import Vapor


final class ServiceData: SQLiteModel {
    
    var id: Int?
    var serviceName: String
    var userName: String
    var apiKey: String
    var apiSecret: String
    
    init(id: Int? = nil, serviceName: String, userName: String, apiKey: String, apiSecret: String) {
        self.serviceName = serviceName
        self.userName = userName
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }
}


/// Allows `PriorityMapList` to be used as a dynamic migration.
extension ServiceData: Migration { }

/// Allows `PriorityMapList` to be encoded to and decoded from HTTP messages.
extension ServiceData: Content { }

/// Allows `PriorityMapList` to be used as a dynamic parameter in route definitions.
extension ServiceData: Parameter { }
