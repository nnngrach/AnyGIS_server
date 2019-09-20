//
//  MapsTester.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 16/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor
import Foundation

class MapTester {
    
    private let baseHandler = SQLHandler()
    private let urlChecker = UrlFIleChecker()
    
    private let correctHtmlStatuses: [UInt] = [200, 303]
    
    
    // Main method
    
    public func testAllMaps(req: Request) -> Future<Response> {
        
        let allMaps = baseHandler.fetchCoordinatesList(req)
        
        return allMaps.flatMap(to: Response.self) { mapsRecords in
            
            let mapsForTesting = mapsRecords.filter{$0.isTesting}
            
            let unallowedMapsListFuture = self.recursiveMapsTesting(iteration: 0, mapsRecords: mapsForTesting, resultList: [], req: req)
            
            return self.prepareResponseWithInfoFrom(unallowedMapsListFuture, req)
        }
    }
    
    
    
    // Callbacks and Futures make me using recursion for iterating for array
    
    private func recursiveMapsTesting(iteration: Int, mapsRecords: [CoordinateMapList], resultList: [String], req: Request) -> Future<[String]> {
        
        // Exit from recursion
        guard iteration < mapsRecords.count  else {return req.future(resultList)}
        
        // New iteration
        var unallowedMapsList: [String] = resultList
        let currentMap = mapsRecords[iteration]
        
        let mapStatusFuture = pingMap(mapName: currentMap.name,
                                            x: currentMap.previewLat,
                                            y: currentMap.previewLon,
                                            z: currentMap.previewZoom,
                                            req: req)
        
        let unallowedMapsListFuture = mapStatusFuture.flatMap(to: [String].self) { status in
            
            if !self.correctHtmlStatuses.contains(status.code) {
                
                unallowedMapsList.append("\(status.code) - " + currentMap.name)
            }
            
            //print(iteration, "/", mapsRecords.count, "  ", status.code, currentMap.name)
            
            // To next iteration
            let nextIterationResult = self.recursiveMapsTesting(iteration: iteration+1, mapsRecords: mapsRecords, resultList: unallowedMapsList, req: req)
            
            return nextIterationResult
        }
        
        return unallowedMapsListFuture
    }
    
    
    
    
    
    private func prepareResponseWithInfoFrom(_ unallowedMapsListFuture: Future<[String]>, _ req: Request) -> Future<Response> {
        
        return unallowedMapsListFuture.map(to: Response.self) { unallowedMaps in
            
            if unallowedMaps.count == 0 {
                return self.sendResponse(200, "All maps OK", req)
            } else {
                return self.sendResponse(500, "\(unallowedMaps)", req)
            }
        }
    }
    
    
    
    
    private func pingMap(mapName: String, x: Double, y: Double, z: Int, req: Request) -> Future<HTTPResponseStatus> {
        
        let anygisMapUrl = SERVER_HOST + mapName + "/" + String(x) + "/" + String(y) + "/" + String(z)
        
        //let anygisMapUrl = "http://localhost:8080/api/v1/" + mapName + "/" + String(x) + "/" + String(y) + "/" + String(z)
        
        //print(anygisMapUrl)
        //return urlChecker.anotherChecker(url: anygisMapUrl, req: req)
        
        
//        do {
//            return try urlChecker.checkUrlStatusAndProxy(anygisMapUrl, nil, nil, req)
//        } catch {
//            return req.future(HTTPResponseStatus(statusCode: 502))
//        }
        
       
        return urlChecker.checkUrlStatus("anygis.ru", "any", anygisMapUrl, false, req: req)
    }
    
    
    
    
    
    private func sendResponse(_ status: Int, _ text: String, _ req: Request) -> Response {
        
        let errorResponse = HTTPResponse(status: HTTPResponseStatus(statusCode: status), body: text)
        
        return Response(http: errorResponse, using: req)
    }
    
}
