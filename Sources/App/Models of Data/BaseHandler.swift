//
//  BaseHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.

import Vapor
import FluentSQLite

class BaseHandler {
    
    
    func listJSON(_ request: Request) throws -> Future<[MapData]> {
        return MapData.query(on: request).all()
    }
    
    func listOverlayJSON(_ request: Request) throws -> Future<[OverlayMapList]> {
        return OverlayMapList.query(on: request).all()
    }
    
    
    /*
    func listJSON2(_ request: Request) throws -> Future<[MapData]> {
        let a = MapData.query(on: request).all()
        a.do {user in
            user[0].mode
        }.catch { error in
            throw error
        }
        return a
    }
 */
    
    
//    func list (_ request: Request) throws -> [MapData] {
//        return try listJSON(request).wait()
//    }
    
//    func list (_ request: Request) throws -> [MapData] {
//        let promise = request.eventLoop.newPromise(Void.self)
//
//        var result = [MapData]()
//
//        DispatchQueue.global() {
//            //sleep(5)
//            result = try listJSON(request).wait()
//            promise.succeed()
//        }
//
//        return promise.futureResult.transform(to: result)
//
//
//        return try listJSON(request).wait()
//    }
    
    
    func getBy (mapName: String, _ request: Request) throws -> Future<MapData>  {
        return MapData.query(on: request)
            .filter(\MapData.name == mapName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping MapData error")))
    }
    

    
    func getBy(objectId: Int, _ request: Request) throws -> Future<MapData> {
        return MapData.find(objectId, on: request).map(to: MapData.self) { post in
            guard let post = post else { throw Abort.init(HTTPStatus.notFound) }
            return post
        }
    }
    

    
//    func getFirstWith (mapName: String, _ request: Request) throws -> MapData {
//        return try MapData.query(on: request)
//            .filter(\MapData.name == mapName)
//            .first()
//            .unwrap(or: Abort.init(
//                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping MapData error")))
//            .wait()
//    }
    
    
    
    func getOverlayBy (setName: String, _ request: Request) throws -> Future<OverlayMapList>  {
        return OverlayMapList.query(on: request)
            .filter(\OverlayMapList.setName == setName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping OverlayMapList error")))
    }

    
    
    
    
}
