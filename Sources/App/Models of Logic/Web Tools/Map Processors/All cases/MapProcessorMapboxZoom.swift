//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorMapboxZoom: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        guard cloudinarySessionID != nil && mapboxSessionId != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        
        // Load layers info from data base in Future format
        let mapList = try self.sqlHandler.getMirrorsListBy(setName: mapName, req)
        
        return mapList.flatMap(to: Response.self) { mapListData  in
            
            let mapboxIndex = Int(self.paralleliser.getMapboxSessionId()) ?? 0
            
            let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapListData[mapboxIndex].url, "")
            
            let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, cloudinarySessionID!, req)
            
            // Get URL of resulting file in image-processor storage
            return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                
                let processedImageUrl = self.imageProcessor.getUrlWithZooming(fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, cloudinarySessionID!)
                
                return self.output.redirect(to: processedImageUrl, with: req)
                
            }
        }
    }
    
}
