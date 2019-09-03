//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorProxy: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        //guard cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        print("==========================")
        print("proxy")
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        print(newUrl)
        
        let tile = try req.client().get(newUrl)
        print("tile loaded")
        
        return tile
        
    }
    
}
