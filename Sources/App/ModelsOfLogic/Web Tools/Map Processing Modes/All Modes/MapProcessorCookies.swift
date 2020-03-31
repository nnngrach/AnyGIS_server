//
//  MapProcessorCookies.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 26/10/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//


// TODO: Not finished!

import Vapor

class MapProcessorCookies: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
        
        let userAgent = USER_AGENT
        
        let headers = HTTPHeaders([("referer", mapObject.referer),
                                   ("User-Agent", userAgent),
                                   ("Cookie", "JSESSIONID=004FF0E893760BA2EAFA8A0EBD8FEED9; JSESSIONID_MWEB=89CEC35B500F8B92FD8D13C4687AC51F; _ga=GA1.2.995512139.1572103230; _gid=GA1.2.2048170066.1572103230")])
        
        
        
        

        let fullResponce = try req.client().get(newUrl, headers: headers)
        
        // Some original headers making errors. Erase it.
        
        let bodyResponce = fullResponce.flatMap(to: Response.self) { res in
            
            let body = res.http.body
 
            let response = Response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: 200), body: body), using: req)
            
            return req.future(response)
        }
       
        return bodyResponce
    }
    
}
