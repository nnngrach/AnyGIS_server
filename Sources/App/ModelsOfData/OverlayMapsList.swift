import FluentSQLite
import Vapor


final class OverlayMapsList: SQLiteModel {
    
    var id: Int?
    var setName: String
    var baseName: String
    var overlayName: String
    
    init(id: Int? = nil, setName: String, baseName: String, overlayName: String) {
        self.setName = setName
        self.baseName = baseName
        self.overlayName = overlayName
    }
}


/// Allows `OverlayMapList` to be used as a dynamic migration.
extension OverlayMapsList: Migration { }

/// Allows `OverlayMapList` to be encoded to and decoded from HTTP messages.
extension OverlayMapsList: Content { }

/// Allows `OverlayMapList` to be used as a dynamic parameter in route definitions.
extension OverlayMapsList: Parameter { }
