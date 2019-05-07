//
//  AbstractMapProcessorSimple.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class AbstractMapProcessorSimple {
    
    let coordinateTransformer = CoordinateTransformer()
    let paralleliser = FreeAccountsParalleliser()
    let urlPatchCreator =  URLPatchCreator()
    let output = OutputResponceGenerator()
    let imageProcessor = ImageProcessor()
    let urlChecker = UrlFIleChecker()
    let sqlHandler = SQLHandler()
    
    
    public func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList), _ req: Request) throws -> EventLoopFuture<Response> {
        
        return try makeCustomActions(mapName, tileNumbers, nil, mapObject, nil, nil, nil, nil, req)
    }
    
    
    func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        return req.future(Response(http: HTTPResponse(status: .notFound), using: req))
    }
    
}
