//
//  MapProcessorOpacity.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 08/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor

class MapProcessorOpacity: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        
        return try imageProcessor.opacity(value: mapObject.parameters, url: newUrl, req: req)
    }
    
}
