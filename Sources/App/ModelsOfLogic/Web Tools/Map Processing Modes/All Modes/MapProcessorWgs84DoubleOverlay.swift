//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorWgs84DoubleOverlay: AbstractMapProcessorWgs84Double {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
                
        guard tilePosition != nil && cloudinarySessionID != nil && baseObject != nil && overlayObject != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        // To make one image with offset I need four nearest to crop.
        let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition!.x, tilePosition!.y, tileNumbers.z, baseObject!)
        
        let fourOverTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition!.x, tilePosition!.y, tileNumbers.z, overlayObject!)
        
        
        // Upload all images to online image-processor
        let loadingResponces = try self.cloudinaryImageProcessor.uploadFourTiles(fourTilesAroundUrls, cloudinarySessionID!, req)

        let loadingOverResponces = try self.cloudinaryImageProcessor.uploadFourTiles(fourOverTilesAroundUrls, cloudinarySessionID!, req)
        
        
        // Get URL of resulting file in image-processor storage
        return self.cloudinaryImageProcessor.syncFour(loadingResponces, req) { res1 in
            return self.cloudinaryImageProcessor.syncFour(loadingOverResponces, req) { res2 in
                
                let processedImageUrl = self.cloudinaryImageProcessor.getUrlWithOffsetAndDoubleOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition!.offsetX, tilePosition!.offsetY, cloudinarySessionID!)
                
                return self.output.redirect(to: processedImageUrl, with: req)
            }
        }
    }
    
}

