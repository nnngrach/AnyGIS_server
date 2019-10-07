//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorNavionics: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileUrlBase = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
        
        
        let autherUrl = mapObject.backgroundServerName + String(Int(NSDate().timeIntervalSince1970)) + "123"
        
        let headers: HTTPHeaders = ["Origin": "https://webapp.navionics.com",
                                    "Referer": "https://webapp.navionics.com/",
                                    "User-Agent": USER_AGENT]
        

        
        let fullResponce = try req.client()
            .get(autherUrl, headers: headers)
            .flatMap(to: Response.self) { authAnswer in
                
                let secretCode = "\(authAnswer.http.body)"
                
                let tileUrlWithCode = tileUrlBase + secretCode
                
                // return try req.client().get(tileUrlWithCode, headers: headers)
                
                let a = try req.client().get(tileUrlWithCode, headers: headers)
                
                a.map { b in
                    print(b)
                }
                
                return a
        }
        
        return fullResponce
    }
    
}

