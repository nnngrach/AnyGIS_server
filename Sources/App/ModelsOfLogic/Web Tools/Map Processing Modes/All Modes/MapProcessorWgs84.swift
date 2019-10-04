//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorWgs84: AbstractMapProcessorWgs84 {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        guard tilePosition != nil && cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        // To make image with offset I'm cropping one image from four nearest images.
        let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition!.x, tilePosition!.y, tileNumbers.z, mapObject)
        
       
        let isNoNeedToMoveImage = (tilePosition!.offsetX == 0) && (tilePosition!.offsetY == 0)
        
        
        if isNoNeedToMoveImage {
            return output.redirect(to: fourTilesAroundUrls[0], with: req)
        
        } else {
            let response = try imageProcessor.move(tilesUrl: fourTilesAroundUrls, xOffset: tilePosition!.offsetX, yOffset: tilePosition!.offsetY, req: req)
            
            return response
        }
        
    }
    
}

