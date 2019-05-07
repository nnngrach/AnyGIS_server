//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorNavionics: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ mapboxSessionId: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileUrlBase = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        
        let checkerURL = mapObject.backgroundServerName + String(Int(NSDate().timeIntervalSince1970))
        
        let headers: HTTPHeaders = ["Origin": "http://webapp.navionics.com",
                                    "Referer": "http://webapp.navionics.com/"]
        
        
        let resultResponse = try req
            .client()
            .get(checkerURL, headers: headers)
            .flatMap(to: Response.self) { checkerAnswer in
                
                let secretCode = "\(checkerAnswer.http.body)"
                
                let fullURL = tileUrlBase + secretCode
                
                let connection = HTTPClient.connect(hostname: "backend.navionics.io", connectTimeout: .milliseconds(500), on: req)
                
                
                let result = connection.flatMap(to: Response.self) { client in
                    
                    let request = HTTPRequest(method: .GET, url: fullURL, headers: headers, body: "")
                    let response = client
                        .send(request)
                        .map(to: Response.self) { httpRes in
                            
                            return Response(http: httpRes, using: req)
                    }
                    
                    return response
                }
                
                return result
        }
        
        return resultResponse

    }
    
}

