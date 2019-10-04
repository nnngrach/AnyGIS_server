//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorWgs84Overlay: AbstractMapProcessorWgs84Double {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        guard tilePosition != nil && cloudinarySessionID != nil && baseObject != nil && overlayObject != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        // To make one image with offset I need four nearest to crop.
        let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition!.x, tilePosition!.y, tileNumbers.z, baseObject!.backgroundUrl, baseObject!.backgroundServerName)
        
        let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, overlayObject!.backgroundUrl, overlayObject!.backgroundServerName)
        
        
        
        let isNoNeedToMoveImage = (tilePosition!.offsetX == 0) && (tilePosition!.offsetY == 0)
        
        
        if isNoNeedToMoveImage {
            return try imageProcessor.overlay(backgroundUrl: fourTilesAroundUrls[0], overlayUrl: overlayUrl, req: req)
            
        } else {
            return try imageProcessor.moveAndOverlay(tilesUrl: fourTilesAroundUrls, xOffset: tilePosition!.offsetX, yOffset: tilePosition!.offsetY, overlayUrl: overlayUrl, req: req)
        }
        
    }
    
}

