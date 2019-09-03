//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorProxy: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
      
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
       
        let fullResponce = try req.client().get(newUrl)
        
        // Some original headers making errors. Erase it.
        
        let bodyResponce = fullResponce.flatMap(to: Response.self) { res in
            
            let body = res.http.body
            
            let response = Response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: 200), body: body), using: req)
            
            return req.future(response)
        }
        
        return bodyResponce
    }
    
}
