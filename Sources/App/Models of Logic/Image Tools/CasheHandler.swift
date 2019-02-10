//
//  CasheHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation
import Vapor


class CasheHandler {
    
    public func erase(_ req: Request) throws {
        // Check time
        
        // Check uploaded count
        // Erase uploaded
        
        // Check fetched count
        // Erase fetched
        
    
        try uploadOneTile("https://a.tile.openstreetmap.org/0/0/0.png", "0", req)
    }
    

    
    
    public func uploadOneTile(_ sourceUrl: String, _ sessionID: String, _ request: Request) throws{
        
        let host = "https://api.cloudinary.com/v1_1/anygis" + sessionID + "/image/upload"
        let name = "img_testingTimer_" + String(NSDate().timeIntervalSince1970)
        
        let message = CloudinaryPostMessage(file: sourceUrl,
                                            public_id: name,
                                            upload_preset: "guestPreset")
        
        let postResponse = try request.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
    }
    
    
}
