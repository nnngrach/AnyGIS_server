//
//  MapProcessorYaPogoda.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 19.05.2020.
//  Copyright © 2020 Nnngrach. All rights reserved.
//


import Vapor

class MapProcessorYaPogoda: AbstractMapProcessorSimple {
    
    
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
    
        
        // Fetch correct unix time value
        
        let authHelpinObject = MapsList(name: "", mode: "", backgroundUrl: mapObject.backgroundServerName, backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 20, dpiSD: "", dpiHD: "", parameters: 0, description: "")
        
        let authCalculatedUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, authHelpinObject)
        
        let aurhHeaders: HTTPHeaders = ["Referer": "https://yandex.ru/pogoda/moscow/maps/nowcast?via=mmapwb&ll=39.056220_50.965158&z=5&le_Lightning=1",
                                    "User-Agent": USER_AGENT]
        
        
        

        let fullResponce = try req.client()
            .get(authCalculatedUrl, headers: aurhHeaders)
            .flatMap(to: Response.self) { res in
                
                // extract unix time value from server answer
                let bodyText = "\(res.http.body)"
                let correctUnixTime = bodyText.slice(from: "\"GenTime\":", to: ",") ?? ""
                
                
                // calculate url of tile to download
                var tileUrlBase = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
                
                tileUrlBase = tileUrlBase.replacingOccurrences(of: "{yaPogodaUnixTime}", with: correctUnixTime)
                
                //return req.redirect(to: tileUrlBase)
                
                let tileHeaders: HTTPHeaders = ["Referer": mapObject.referer,
                                                "User-Agent": USER_AGENT]
                
                // and download it
                //let tileRes = try req.client().get(tileUrlBase, headers: tileHeaders)
                let tileRes = try req.client().get(tileUrlBase)
                //return tileRes
                
                let bodyResponce = tileRes.flatMap(to: Response.self) { res in
                    
                    let body = res.http.body
                    
                    let response = Response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: 200), body: body), using: req)
                    
                    return req.future(response)
                }
                
                return bodyResponce
                
                
            }
        
        return fullResponce
    }
    
}



fileprivate struct YaPogodaAuthJson: Codable {
    var GenTime: Int?
}
