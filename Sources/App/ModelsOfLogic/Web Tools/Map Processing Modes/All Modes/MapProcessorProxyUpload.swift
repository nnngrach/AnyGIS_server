//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 11/05/2019.
//

import Vapor

// TODO: DEPRECATED

class MapProcessorProxyUpload: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        guard cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
        
        let loadingResponces = try cloudinaryImageProcessor.uploadOneTile(newUrl, cloudinarySessionID!, req)
        
        
        return self.cloudinaryImageProcessor.syncOne(loadingResponces, req) {res in
            let url = self.cloudinaryImageProcessor.getUrl(newUrl, cloudinarySessionID!)
            return self.output.redirect(to: url, with: req)
        }
    }
    
}
