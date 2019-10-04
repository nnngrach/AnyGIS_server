//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorMapboxZoom: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        guard cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        let mapboxSessionId = try self.paralleliser.getMapboxSessionId()
        
        // Load layers info from data base in Future format
        let mapList = try self.sqlHandler.getMirrorsListBy(setName: mapName, req)
        
        return mapList.flatMap(to: Response.self) { mapListData  in
            
            let mapboxIndex = Int(self.paralleliser.getMapboxSessionId()) ?? 0
            
            let mapTemplate = MapsList(name: "", mode: "", backgroundUrl: mapListData[mapboxIndex].url, backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 0, dpiSD: "", dpiHD: "", parameters: 0, description: "")
            
            let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapTemplate)
            
            let loadingResponces = try self.cloudinaryImageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, cloudinarySessionID!, req)
            
            // Get URL of resulting file in image-processor storage
            return self.cloudinaryImageProcessor.syncFour(loadingResponces, req) { res1 in
                
                let processedImageUrl = self.cloudinaryImageProcessor.getUrlWithZooming(fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, cloudinarySessionID!)
                
                return self.output.redirect(to: processedImageUrl, with: req)
                
            }
        }
    }
    
}
