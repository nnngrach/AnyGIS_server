//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorOverlay: AbstractMapProcessorOverlay {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        guard baseObject != nil && overlayObject != nil && cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, baseObject!.backgroundUrl, baseObject!.backgroundServerName)
        
        let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.x, overlayObject!.backgroundUrl, overlayObject!.backgroundServerName)
        
        
        // Upload all images to online image-processor
        let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], cloudinarySessionID!, req)
        
        
        // Redirect to URL of resulting file in image-processor storage
        return self.imageProcessor.syncTwo(loadingResponces, req) { res in
            
            let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl, cloudinarySessionID!)
            return self.output.redirect(to: newUrl, with: req)
        }
    }
    
}
