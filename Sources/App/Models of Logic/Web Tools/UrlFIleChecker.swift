//
//  UrlChecker.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 04/02/2019.
//

import Foundation
import Vapor

// Recursive checkers for file existing by URL

class UrlFIleChecker {
    
    let sqlHandler = SQLHandler()
    let output = OutputResponceGenerator()
    let urlPatchCreator = URLPatchCreator()
    let coordinateTransformer = CoordinateTransformer()
    let imageHandler = ImageProcessor() // I use Cloudinary like a proxy
    
    var delegate: WebHandlerDelegate?
    
    
    // Checker for MultyLayer mode
    
    
    public func checkMultyLayerList(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {

        let currentMapName = maps[index].mapName

        
        // Quick redirect for maps with global coverage
        guard !maps[index].notChecking else {
            
            let response1 = try delegate!.startSearchingForMap(currentMapName, xText: String(x), String(y), z, req)
            
            return try resultChecker(response1, maps, index, x, y, z, req)
        }

        

        // Filter checking maps by it's coverage area
        let coordinates = coordinateTransformer.tileNumberToCoordinates(x, y, z)
        let xRange = maps[index].xMin ... maps[index].xMax
        let yRange = maps[index].yMin ... maps[index].yMax

        let defaultValue = 0.0...0.0
        let isMapWithoutLimits = (xRange == defaultValue && xRange == defaultValue)
        let isPointInCoverageArea = xRange.contains(coordinates.lon_deg) && yRange.contains(coordinates.lat_deg)

        guard isMapWithoutLimits || isPointInCoverageArea else {
            return try checkMultyLayerList(maps, index+1, x, y, z, req)
        }


        // Start checking maps existing
        var redirectingResponse: Future<Response>

        let response = try checkMirrorsList(currentMapName, x, y, z, req)

        redirectingResponse = try resultChecker(response, maps, index, x, y, z, req)

        return redirectingResponse
    }
    
    
    
    private func resultChecker(_ response: EventLoopFuture<Response>, _ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        return response.flatMap(to: Response.self) { res in
            
            if (res.http.status.code == 404) && (maps.count > index+1) {
                // print("Recursive find next ")
                return try self.checkMultyLayerList(maps, index+1, x, y, z, req)
                
            } else if(res.http.status.code == 404) {
                // print("Fail ")
                return self.output.notFoundResponce(req)
                
            } else {
                // print("Success ")
                return req.future(res)
            }
        }
    }
    
    
    
    
    // Checker for Mirrors mode
    public func checkMirrorsList(_ mirrorName: String, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        // Load info for every mirrors from data base in Future format
        let mirrorsList = try sqlHandler.getMirrorsListBy(setName: mirrorName, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = mirrorsList.flatMap(to: Response.self) { mirrorsListData  in
            
            guard mirrorsListData.count != 0 else {return self.output.notFoundResponce(req)}
            
            let urls = mirrorsListData.map {$0.url}
            let hosts = mirrorsListData.map {$0.host}
            let patchs = mirrorsListData.map {$0.patch}
            let ports = mirrorsListData.map {$0.port}
            
            var firstFoundedUrlResponse : Future<Response>
            
            // Custom randomized iterating of array
            let startIndex = 0
            let shuffledOrder = makeShuffledOrder(maxNumber: mirrorsListData.count)
            
            // File checker
            let firstCheckingIndex = shuffledOrder[startIndex] ?? 0
            
            
            if hosts[firstCheckingIndex] == "dont't need to check" {
                // Global maps. Dont't need to check it
                let newUrl = self.urlPatchCreator.calculateTileURL(x, y, z, urls[firstCheckingIndex], "")
                
                //firstFoundedUrlResponse = self.output.redirect(to: newUrl, with: req)
                firstFoundedUrlResponse = self.output.redirectWithReferer(to: newUrl, referer: nil, with: req)
                
            } else {
                // Local maps. Start checking of file existing for all mirrors URLs
                firstFoundedUrlResponse = self.findExistingMirrorNumber(index: startIndex, hosts, ports, patchs, urls, x, y, z, shuffledOrder, req: req)
            }
            
            return firstFoundedUrlResponse
        }
        
        return redirectingResponce
    }
    
    
    
    

    
    // Mirrors mode recursive checker sub function
    private func findExistingMirrorNumber(index: Int, _ hosts: [String], _ ports: [String], _ patchs: [String], _ urls: [String], _ x: Int, _ y: Int, _ z: Int, _ order: [Int:Int], req: Request) -> Future<Response> {
        
        guard let currentShuffledIndex = order[index] else {return output.notFoundResponce(req)}
        
        
        let currentPatchUrl = self.urlPatchCreator.calculateTileURL(x, y, z, patchs[currentShuffledIndex], "")
        
        let responceStatus = checkUrlStatus(hosts[currentShuffledIndex], ports[currentShuffledIndex], currentPatchUrl, req: req)
        
        
        let firstFoundedFileResponce = responceStatus.flatMap{ (status) -> Future<Response> in
            
            if status.code != 403 && status.code != 404 {
                //print ("Success: File founded! ", hosts[index], currentUrl, response.status.code)
                let newUrl = self.urlPatchCreator.calculateTileURL(x, y, z, urls[currentShuffledIndex], "")
                //return self.output.redirect(to: newUrl, with: req)
                return self.output.redirectWithReferer(to: newUrl, referer: nil, with: req)
                
            } else if (index + 1) < hosts.count {
                //print ("Recursive find for next index: ", hosts[index], currentUrl, response.status.code)
                return self.findExistingMirrorNumber(index: index+1, hosts, ports, patchs, urls, x, y, z, order, req: req)
                
            } else {
                //print("Fail: All URLs checked and file not founded. ", response.status.code)
                return self.output.notFoundResponce(req)
            }
        }
        
        return firstFoundedFileResponce
    }
    
    
    
    
    
    private func checkUrlStatus(_ host: String, _ port: String, _ url: String, req: Request) -> Future<HTTPResponseStatus> {
        
        let timeout = 500       //TODO: I need to increase this speed
        let defaultPort = 8080
        var connection: EventLoopFuture<HTTPClient>

        // Connect to Host URL with correct port
        if port == "any" {
            connection = HTTPClient.connect(hostname: host, on: req)
            
        } else {
            let portNumber = Int(port) ?? defaultPort
            connection = HTTPClient.connect(hostname: host, port: portNumber, connectTimeout: .milliseconds(timeout), on: req)
        }
        
        
        // Synchronization: Waiting, while coonection will be started
        let responseStatus = connection.flatMap { client -> Future<HTTPResponseStatus> in
            
            let request = HTTPRequest(method: .HEAD, url: url)
            
            let response = client.send(request)
            
            let status = response.flatMap { res -> Future<HTTPResponseStatus> in
                return req.future(res.status)
            }
            
            return status
            
        }.catchFlatMap { error in
            
            return req.future(HTTPResponseStatus(statusCode: 404))
        }
        
        return responseStatus
    }
    
    
    
    
    public func checkUrlStatusAndProxy(_ url: String, _ sessionID: String, _ req: Request) throws -> Future<HTTPResponseStatus> {
        
        let checkingResponse = try req.client().get(url)
        
        let resultResponce = checkingResponse.map(to: HTTPResponseStatus.self) { res in
            return res.http.status
        }
        
        return resultResponce
    }
    
    
    
}
