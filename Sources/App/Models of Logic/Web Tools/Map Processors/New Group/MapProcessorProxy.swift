//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorProxy: AbstractMapProcessorSession {
    
    let urlChecker = UrlFIleChecker()
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList),  _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        guard cloudinarySessionID != nil else {return try output.serverErrorResponce("Cloudinary ID unwarping error", req)}
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        let checkedStatus = try self.urlChecker.checkUrlStatusAndProxy(newUrl, nil, nil, req)
        
        let resultResponse = checkedStatus.map(to: Response.self) { status in
            
            var url = ""
            
            if status.code == 200 {
                url = newUrl
            } else {
                url = self.imageProcessor.getDirectUrl(url, cloudinarySessionID!)
            }
            
            return req.redirect(to: url)
        }
        
        return resultResponse
    
    }
    
}
