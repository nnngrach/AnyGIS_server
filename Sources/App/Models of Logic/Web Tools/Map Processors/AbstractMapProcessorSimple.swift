//
//  AbstractMapProcessorSimple.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class AbstractMapProcessorSimple {
    
    let urlPatchCreator =  URLPatchCreator()
    let output = OutputResponceGenerator()
    
    public func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList), _ req: Request) throws -> EventLoopFuture<Response> {
        
        return try makeCustomActions(mapName, tileNumbers, mapObject, nil, nil, req)
    }
    
    
    func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList),  _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        return req.future(Response(http: HTTPResponse(status: .notFound), using: req))
    }
    
}
