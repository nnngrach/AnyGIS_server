//
//  MapProcessorRedirect.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class MapProcessorProxy: AbstractMapProcessorSession {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
       
        let isRefererFilled = mapObject.referer.replacingOccurrences(of: " ", with: "") != ""
        
        var fullResponce: Future<Response>
        
        
        if isRefererFilled {
            
            let headers = getCustomHeaders(mapObject)
            
//            let headers = HTTPHeaders(
//                [("referer", mapObject.referer),
//                 ("origin", mapObject.referer),
//                 ("User-Agent", USER_AGENT)])
            
            fullResponce = try req.client().get(newUrl, headers: headers)
            
        } else {
            
            fullResponce = try req.client().get(newUrl)
        }
        

        
        // Some original headers making errors. Erase it.
        
        let bodyResponce = fullResponce.flatMap(to: Response.self) { res in
            
            let body = res.http.body
            
            let response = Response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: 200), body: body), using: req)
            
            return req.future(response)
        }
        
        return bodyResponce
    }
    
    
    
    func getCustomHeaders(_ mapObject: (MapsList)) -> HTTPHeaders {
        
        var parameters: [(String, String)] = []
        
        let stringWithParameters = mapObject.referer
        let isHeadersСomposite = stringWithParameters.contains(";")
        
        if !isHeadersСomposite{
            parameters = [("referer", mapObject.referer),("origin", mapObject.referer)]
            
        } else {
            let splittedParamerers = stringWithParameters.components(separatedBy: ";")
            
            for i in 0 ..< splittedParamerers.count where (i % 2 == 0) {
                parameters.append((splittedParamerers[i], splittedParamerers[i+1]))
            }
        }
        
        parameters.append(("User-Agent", USER_AGENT))
        
        return HTTPHeaders(parameters)
    }
}
