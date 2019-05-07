//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorWgs84: AbstractMapProcessorWgs84 {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        guard tilePosition != nil && cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        // To make image with offset I'm cropping one image from four nearest images.
        let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition!.x, tilePosition!.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        // Upload all images to online image-processor
        let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, cloudinarySessionID!, req)
        
        
        // Get URL of resulting file in image-processor storage
        let redirectingResponce = self.imageProcessor.syncFour(loadingResponces, req) { res in
            
            //print(fourTilesAroundUrls)
            
            let processedImageUrl = self.imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition!.offsetX, tilePosition!.offsetY, cloudinarySessionID!)
            
            //print(processedImageUrl)
            
            return self.output.redirect(to: processedImageUrl, with: req)
        }
        
        return redirectingResponce    
    }
    
}

