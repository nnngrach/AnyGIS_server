//
//  MapProcessorText.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 08/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor

class MapProcessorText: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let message = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
        
        let isWhite = mapObject.parameters > 0.5
        
        return try imageProcessor.text(message: message, isWhite: isWhite, req: req)
    }
    
}
