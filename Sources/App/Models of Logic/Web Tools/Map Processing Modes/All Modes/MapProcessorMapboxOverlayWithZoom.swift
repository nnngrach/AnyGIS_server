//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorMapboxOverlayWithZoom: AbstractMapProcessorMapboxOverlay {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        guard baseObject != nil && overlayObject != nil  && cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, baseObject!.backgroundUrl, baseObject!.backgroundServerName)
        
        // To make one image with offset I need four nearest to crop.
        let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, tileNumbers.z, overlayObject!.backgroundUrl, "")
        
        // Upload all images to online image-processor
        let loadingBaseResponce = try self.imageProcessor.uploadOneTile(baseUrl, cloudinarySessionID!, req)
        
        let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, cloudinarySessionID!, req)
        
        
        
        // Get URL of resulting file in image-processor storage
        return self.imageProcessor.syncFour(loadingOverResponces, req) { res1 in
            return self.imageProcessor.syncOne(loadingBaseResponce, req) { res2 in
                
                let processedImageUrl = self.imageProcessor.getUrlWithZoomingAndOverlay(baseUrl, fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, cloudinarySessionID!)
                
                return self.output.redirect(to: processedImageUrl, with: req)
            }
        }
    }
    
    
}
