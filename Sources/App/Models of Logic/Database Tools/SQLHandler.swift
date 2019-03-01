//
//  BaseHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.

import Vapor
import FluentSQLite

class SQLHandler {
    
    public func fetchAllMapsList(_ request: Request) -> Future<[MapsList]> {
        return MapsList.query(on: request)
            .sort(\.name, .ascending)
            .all()
    }
    
    public func fetchMirrorsMapsList(_ request: Request) -> Future<[MirrorsMapsList]> {
        return MirrorsMapsList.query(on: request)
            .sort(\.setName)
            .all()
    }
    
    
    public func fetchOverlayMapsList(_ request: Request) -> Future<[OverlayMapsList]> {
        return OverlayMapsList.query(on: request)
            .sort(\.setName)
            .all()
    }
    
    public func fetchPriorityMapsList(_ request: Request) -> Future<[PriorityMapsList]> {
        return PriorityMapsList.query(on: request)
            .sort(\.setName)
            .sort(\.zoomMin)
            .sort(\.priority)
            .all()
    }
    
    public func fetchServiceList(_ request: Request) -> Future<[ServiceData]> {
        return ServiceData.query(on: request)
            .all()
    }
    
    
    public func fetchAllFileGenInfo(_ request: Request) -> Future<[FileGeneratorDB]> {
        return FileGeneratorDB.query(on: request)
            .sort(\.order)
            .sort(\.clientMapName)
            .all()
    }
    
    public func fetchShortSetFileGenInfo(_ request: Request) -> Future<[FileGeneratorDB]> {
        return FileGeneratorDB.query(on: request)
            .filter(\FileGeneratorDB.isInStarterSet == true)
            .sort(\.order)
            .sort(\.clientMapName)
            .all()
    }
    
    
    
    public func getBy (mapName: String, _ request: Request) throws -> Future<MapsList>  {
        return MapsList.query(on: request)
            .filter(\MapsList.name == mapName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping MapData error")))
    }
    
    
    public func getBy(objectId: Int, _ request: Request) throws -> Future<MapsList> {
        return MapsList.find(objectId, on: request).map(to: MapsList.self) { post in
            guard let post = post else { throw Abort.init(HTTPStatus.notFound) }
            return post
        }
    }
    
    
    
    public func getOverlayBy (setName: String, _ request: Request) throws -> Future<OverlayMapsList>  {
        return OverlayMapsList.query(on: request)
            .filter(\OverlayMapsList.setName == setName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping OverlayMapList error")))
    }
    
    
    public func getPriorityListBy (setName: String, zoom: Int, _ request: Request) throws -> Future<[PriorityMapsList]>  {
        return PriorityMapsList.query(on: request)
            .filter(\.setName == setName)
            .filter(\.zoomMin <= zoom)
            .filter(\.zoomMax >= zoom)
            .sort(\.priority)
            .all()
    }
    
    
    public func getMirrorsListBy (setName: String, _ request: Request) throws -> Future<[MirrorsMapsList]>  {
        
        return MirrorsMapsList.query(on: request)
            .filter(\.setName == setName)
            .all()
    }
    
    
    public func getServiceDataBy (serviceName: String, _ request: Request) throws -> Future<[ServiceData]>  {
        
        return ServiceData.query(on: request)
            .filter(\.serviceName == serviceName)
            .all()
    }
    
    
}
