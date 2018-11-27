import Vapor
import Foundation
import Fluent
import FluentSQLite

final class VaporController {
    
    let controller = IndependentController()

    
    
    func list(_ req: Request) throws -> String {
        return "This function will cooming soon..."
        
    }
    
    
    
    func getById(_ request: Request) throws -> Future<MapData> {
        let objectId = 5
        return MapData.find(objectId, on: request).map(to: MapData.self) { post in
            guard let post = post else { throw Abort.init(HTTPStatus.notFound) }
            return post
        }
    }
    
    
    func filterByKeyword(_ request: Request) throws -> Future<[MapData]> {
        return MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
    }
    

//    func filterByKeyword2(_ request: Request) throws -> Future<[MapData]> {
//        let a = MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
//
//        a.flatMap(to: MapData.self) {maps in
////            let savedUser = map[0].save(on: request) // 3
////            return savedUser
//            let b = try maps.map {
//                return try $0.
//            }
//
//            return map.first
//        }
//        return MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
//    }
    
    
//    func login(_ request: Request) throws  -> Future<MapData> { // 1
//        return try request.content.decode(MapData.self).flatMap(to: MapData.self) { user in // 2
//
//
//            return user. { map in // 3
//                return map
//            }
//
//
//            return user.save(on: request).map(to: MapData.self) { map in // 3
//                return map
//            }
//
//        }
//    }
    
    
    func login(_ request: Request) throws  -> Future<MapData> { // 1
        
        return try request.content.decode(MapData.self).flatMap(to: MapData.self) { user in // 2
        /*
            
            return try MapData(id: user.id, name: user.name, mode: user.mode, backgroundUrl: user.backgroundUrl, backgroundServerName: user.backgroundServerName, overlayUrl: user.overlayUrl, overlayServerName: user.overlayServerName, zoomMin: user.zoomMin, zoomMax: user.zoomMax, description: user.description)
 */
            
            
            
            return user.save(on: request).map(to: MapData.self) { map in // 3

                let mapObject = try MapData(id: map.id, name: map.name, mode: map.mode, backgroundUrl: map.backgroundUrl, backgroundServerName: map.backgroundServerName, overlayUrl: map.overlayUrl, overlayServerName: map.overlayServerName, zoomMin: map.zoomMin, zoomMax: map.zoomMax, description: map.description)
                return mapObject
            }
        }
    }
    
    
   /*
    func login3(_ request: Request) throws  -> Future<PublicUser> { // 1
        return try request.content.decode(User.self).flatMap(to: PublicUser.self) { user in // 2
            return user.save(on: request).map(to: PublicUser.self) { savedUser in // 3
                let publicUser = try PublicUser(email: savedUser.email, id: savedUser.requireID()) // 4
                return publicUser
            }
        }
    }
    */
    
    
    func test(_ req: Request) throws -> String {
        /*
        return try req.parameters.next(MapData.self).flatMap {user in
            return user.delete(on: req)
            }.transform(to: .ok)
        */
        
//        let a = try req.parameters.next(MapData.self)
//        let b = a.flatMap { c in
        
        //MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
        
        let d = MapData.query(on: req).filter(\MapData.name == "Osm_OpenSeaMap").all()
        let e = MapData.query(on: req).filter(\MapData.name == "Osm_OpenSeaMap").first()
        
        
        
        /*
        let f = e.flatMap { g -> MapData in
            let model = MapData(id: g!.id, name: g!.name, mode: g!.mode, backgroundUrl: g!.backgroundUrl, backgroundServerName: g!.backgroundServerName, overlayUrl: g!.overlayUrl, overlayServerName: g!.overlayServerName, zoomMin: g!.zoomMin, zoomMax: g!.zoomMax, description: g!.description)
            return model
        }
 */
        
//        let r = MapData.query(on: req).all()
        let q = MapData.query(on: req)
        let w = q.filter(\MapData.name == "Osm_OpenSeaMap")
//        let t = w.all()
        let t2 = w.first()
//        let t3 = w.decode(MapData.self)
//        let t4 = w.first().transform(to: MapData.self)

        var a = MapData(id: nil, name: "", mode:  "start", backgroundUrl:  "", backgroundServerName:  "", overlayUrl:  "", overlayServerName:  "", zoomMin:  0, zoomMax:  0, description:  "")
        
        
        let y = t2.map({ m in
            a.name = (m!.name)
            a.mode = (m!.mode)
            a.mode = "qweqwe"
//            print(m!.name)
//            print(m!.mode)
            return
        })
        
        
        
        let qqq = t2.map({ m -> String in
            a.name += (m!.name)
            a.mode += (m!.mode)
            a.mode = "qweqweqwe"
            return "qw"
        })

        
        
//        let yy = t2.map { (MapData) -> MapData g in
//            let b = MapData(id: nil, name: g!.name, mode: g!.mode, backgroundUrl: g!.backgroundUrl, backgroundServerName: g!.backgroundServerName, overlayUrl: g!.overlayUrl, overlayServerName: g!.overlayServerName, zoomMin: g!.zoomMin, zoomMax: g!.zoomMax, description: g!.description)
//            return b as MapData
//        }
        
        //print(m)
        
//        [1,2,3].flatMap ({ b in
//            a.mode = "\(b)"
//        })
        
        

        
        return a.mode
        //return "test string"
    }
    
    
    
    func getByViewCount(_ request: Request) throws -> Future<[MapData]> {
        return MapData.query(on: request).filter(\MapData.zoomMin < 500).all()
    }
    
    func filterByKeyword2(_ request: Request) throws -> Future<[MapData]> {
        return MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
    }
    
    //!!!
    func filterByKeyword22(_ request: Request) throws -> Future<MapData> {
        return MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").first().unwrap(or: Abort.init(HTTPResponseStatus.notFound) )
    }
    
    
    
    
    
    // Заработало !!!!
    func filterByKeyword23(_ request: Request) throws -> Future<Response> {
        
        let a = MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").first().unwrap(or: Abort.init(HTTPResponseStatus.notFound))
        
        let responce = a.map(to: Response.self) { c in
            //let result = self.controller.findTile(c.mode, "0", "0", 0)
            let result = self.controller.findTile("img", "0", "0", 0)
            
            switch result {
            case .redirect(let url):
                return request.redirect(to: url)
                
            case .image(let imageData, let extention):
                // It works with png and jpg???
                return request.makeResponse(imageData, as: MediaType.png)
                
            case .error(let desctiption):
                throw desctiption
                
            case .error(let desctiption):
                throw desctiption
                
            default:
                return request.response(http: HTTPResponse(status: .custom(code: 500, reasonPhrase: "My custom error"), body: ""))
            }

        }
        
        return responce
    }
    
    
    
    
    
    
    
    /*
    func filterByKeyword3(_ request: Request) throws -> Future<[MapData]> {
        let a = MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
        
        let product: MapData = try! JSONDecoder().decode(MapData.self, for: a)
        
        return MapData.query(on: request).filter(\MapData.name == "Osm_OpenSeaMap").all()
    }
    */
    
    
    
    
    
    
    
    func startFindingTile(_ req: Request) throws -> Response {
        
        let mapName = try req.parameters.next(String.self)
        let xText = try req.parameters.next(String.self)
        let yText = try req.parameters.next(String.self)
        let zoom = try req.parameters.next(Int.self)
        
        let processingResult = controller.findTile(mapName, xText, yText, zoom)
        
        switch processingResult {
        case .redirect(let url):
            return req.redirect(to: url)
            
        case .image(let imageData, let extention):
            // It works with png and jpg???
            return req.makeResponse(imageData, as: MediaType.png)
/*
            if (extention == "png") {
                return req.makeResponse(imageData, as: MediaType.png)
            } else if (extention == "jpg") || (extention == "jpeg") {
                return req.makeResponse(imageData, as: MediaType.jpeg)
            } else {
                return req.makeResponse(imageData, as: MediaType.png)
                //throw "Unsupportable loaded file extention"
            }
 */
           
        case .error(let desctiption):
            throw desctiption
            
            //return req.makeResponse("Error: " + desctiption)
        }

    }
    
    

    
}


