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
    

    
    func getOverlayBy (setName: String, _ request: Request) throws -> Future<OverlayMapList>  {
        return OverlayMapList.query(on: request)
            .filter(\OverlayMapList.setName == setName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping OverlayMapList error")))
    }

    
    
    
    
}
