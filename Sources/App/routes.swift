import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let vaporController = VaporController()
    

    router.get("", String.parameter, String.parameter, String.parameter,Int.parameter, use: vaporController.startFindingTile)
    
    
    
    
    
    
    
    //вернуть таблицу с названием всех карт и их описанием
    router.get("list", use: vaporController.list)
    
    
    router.get("getby", use: vaporController.getById)
    
    router.get("filter", use: vaporController.filterByKeyword23)
    
    router.get("test", use: vaporController.test)
    
    
 
    // Вернуть изображение по ссылке с указанным значение прозрачности
    //router.get("opacity", Double.parameter, String.parameter, use: controller.splitter)
    
    
    
    let instructionText = """
Welcome to AnyGIS API

This is a utility to connect different navigation applications (web, ios, android)
to map sources with non-standard URLS. It allows you to convert coordinates.
Also it can process tile images.



You can load tile by following to URL with name:
thisSiteName / MapName / xTileNumber / yTileNumber / zoomLevel

For example let's load a Wikimapia tile:

thisSiteName    = https://anygis.herokuapp.com/
MapName         = Wikimapia
xTileNumber     = 549
yTileNumber     = 297
zoomLevel       = 10

Result URL to load this tile will looking like this:
https://anygis.herokuapp.com/Wikimapia/549/297/10

(P.S: Here we uses standart WebMercator tile numbers. Like in OSM or Google maps)



You can also find tile by coordinates:
thisSiteName / MapName / longitude / latitude / zoomLevel
https://anygis.herokuapp.com/Wikimapia/56.062293/37.708244/10



To get full list of maps sources follow this:
https://anygis.herokuapp.com/list




(nnngrach@gmail.com)
(2018)
"""
    
    
    
    router.get { req in
        //return "Welcome to AnyGIS!"
        return instructionText
    }
    
    
    
    //router.get("index", use: vaporController.index)
    
    
    
    
//    router.get("test") { req in
////        let a = MapData.query(on: req).all()
////        a.find(42, on: conn)
//
//        
//        return MapData.find(1, on: req)
////        return MapData.query(on: req).all()
//    }
    
    
    
    
    
//    router.get("sql") { req in
//        return req.withPooledConnection(to: .mysql) { conn in
//            return conn.raw("SELECT @@version as version")
//                .all(decoding: MySQLVersion.self)
//            }.map { rows in
//                return rows[0].version
//        }
//    }
    
//    let res = try MapData.makeQuery()
//        .filter("age" > 60)
//        .filter("catchPhrase" == "Wubba lubba dub-dub!")
//        .all()
    
    
//    let users = try MapData.query(on: conn).filter(\.name == "Vapor").all()
    
//
//    let users = conn.select()
//        .all().from(MapData.self)
//        .where(\MapData.name == "Vapor")
//        .all(decoding: MapData.self)
//    print(users)
    
    
//    router.get("example")
//    {
//        insecure.get("example") {
//            request -> Future<View> in
//            return request.withNewConnection(to: .mysql) {
//                connection in
//                return connection.raw("select * from User").all(decoding: MapData.self).flatMap(to:View.self) {
//                    users in
//                    return try request.make(LeafRenderer.self).render("example",["users":users])
//                }
//            }
//        }
//    }
    
    
//    router.get("singleUser") { request -> Future<MapData> in
////        let userId = 4
////        return try MapData.find(userId, on: request).unwrap(or: Abort.init(HTTPResponseStatus.notFound) )
//        
////        return try MapData.query(on: request).filter(\MapData.keyword == "news").all().unwrap(or: Abort.init(HTTPResponseStatus.notFound) )
//    }
    
    
   
   
    
//    let users = router.grouped("users")
//    users.get(MapData.parameter, use: vaporController.show)
//
    
    
    
    
    
    
    
}


