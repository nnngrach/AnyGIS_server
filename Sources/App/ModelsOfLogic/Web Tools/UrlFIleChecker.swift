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
    let imageHandler = CloudinaryImageProcessor() // I use Cloudinary like a proxy
    
    var delegate: WebHandlerDelegate?
    
    
    // MARK: Checker for MultyLayer mode
    
    public func checkMultyLayerList(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        guard index < maps.count else {return self.output.notFoundResponce(req)}
        
        
        let currentMapName = maps[index].mapName
        
        // Quick redirect for maps with global coverage
        guard !maps[index].notChecking else {
            
            let fastResponse = try delegate!.startSearchingForMap(currentMapName, xText: String(x), String(y), z, req)
            
            return try resultChecker(fastResponse, maps, index, x, y, z, req)
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
            
            //print(res.http.status.code, res.http.headers.firstValue(name: HTTPHeaderName("location")))
            
            if (res.http.status.code == 404) && (maps.count > index+1) {
                // print("Recursive find next ")
                return try self.checkMultyLayerList(maps, index+1, x, y, z, req)
                
            } else if(res.http.status.code == 404) {
                // print("Fail ")
                return self.output.notFoundResponce(req)
                
            } else {
                
                if try self.isTileEmpry(req: req, res: res) {
                    // print("Tile is empty ")
                    return try self.checkMultyLayerList(maps, index+1, x, y, z, req)
                } else {
                    // print("Success ")
                    return req.future(res)
                }
                
//                let responseWithImage = try self.isTileEmpry(req: req, res: res)
//
//                return responseWithImage.flatMap(to: Response.self) { res in
//                    if (res.http.status.code == 404) {
//                        // print("Tile is empty ")
//                        return try self.checkMultyLayerList(maps, index+1, x, y, z, req)
//                    } else {
//                        // print("Success ")
//                        return req.future(res)
//                    }
//                }
            }
        }
    }
    
    
    
    // Is this tile empry or with error text message
    private func isTileEmpry (req: Request, res: Response) throws -> Bool {
        
        //print("isTileEmpry")
        
        let problemMapsList =
            [(url: "http://maps.marshruty.ru", errorTileSize: 7600),
            //(url: "http://ingreelab.net", errorTileSize: 103),
            //(url: "https://services.sentinel-hub.com", errorTileSize: 800)
        ]
        
        var sizeOfErrorTile = 0
        
        // filter off regular maps
        var isCurrentMapInList = false
        let checkedUrl = res.http.headers.firstValue(name: HTTPHeaderName("location")) ?? ""
        
        for problemMap in problemMapsList {
            if checkedUrl.hasPrefix(problemMap.url) {
                isCurrentMapInList = true
                sizeOfErrorTile = problemMap.errorTileSize
            }
        }
       
        guard isCurrentMapInList else {return false}
        //guard isCurrentMapInList else {return output.redirect(to: checkedUrl, with: req)}
        
        
        
        // for problem maps
        let currentHttpBodySize = res.http.body.count ?? 0
        return currentHttpBodySize <= sizeOfErrorTile
        
//        let responseWithImage = try req.client().get(checkedUrl)
//
//        let resultResponse = responseWithImage.flatMap(to: Response.self) { response in
//            let currentHttpBodySize = response.http.body.count ?? 0
//
//            if currentHttpBodySize < sizeOfErrorTile {
//                return self.output.notFoundResponce(req)
//            } else {
//                return req.future(res)
//            }
//        }
//
//        return resultResponse
        
        //print(checkedUrl)
        //print(currentHttpBodySize)
        //print(currentHttpBodySize < sizeOfMarshrutyRuErrorTile)
    }
    
    
    
    // MARK: Checker for Mirrors mode
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
            let isHttps = mirrorsListData.map {$0.isHttps}
            
            var firstFoundedUrlResponse : Future<Response>
            
            // Custom randomized iterating of array
            let startIndex = 0
            let shuffledOrder = makeShuffledOrder(maxNumber: mirrorsListData.count)
            
            // File checker
            let firstCheckingIndex = shuffledOrder[startIndex] ?? 0
            
            
            if hosts[firstCheckingIndex] == "dont't need to check" {
                // Global maps. Dont't need to check it
                
                let mapTemplate = MapsList(name: "", mode: "", backgroundUrl: urls[firstCheckingIndex], backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 0, dpiSD: "", dpiHD: "", parameters: 0, description: "")
                
                let newUrl = self.urlPatchCreator.calculateTileURL(x, y, z, mapTemplate)
                
                //firstFoundedUrlResponse = self.output.redirect(to: newUrl, with: req)
                firstFoundedUrlResponse = self.output.redirectWithReferer(to: newUrl, referer: nil, with: req)
                
            } else {
                // Local maps. Start checking of file existing for all mirrors URLs
                firstFoundedUrlResponse = self.findExistingMirrorNumber(index: startIndex, hosts, ports, patchs, urls, isHttps, x, y, z, shuffledOrder, req: req)
            }
            
            return firstFoundedUrlResponse
        }
        
        return redirectingResponce
    }
    
    
    
    

    
    // MARK: Mirrors mode recursive checker sub function
    private func findExistingMirrorNumber(index: Int, _ hosts: [String], _ ports: [String], _ patchs: [String], _ urls: [String], _ protocols: [Bool], _ x: Int, _ y: Int, _ z: Int, _ order: [Int:Int], req: Request) -> Future<Response> {
        
        
        guard let currentShuffledIndex = order[index] else {return output.notFoundResponce(req)}
        
        let mapTemplate = MapsList(name: "", mode: "", backgroundUrl: patchs[currentShuffledIndex], backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 0, dpiSD: "", dpiHD: "", parameters: 0, description: "")
        
        let currentPatchUrl = self.urlPatchCreator.calculateTileURL(x, y, z, mapTemplate)
        
        
        let responceStatus = checkUrlStatus(hosts[currentShuffledIndex], ports[currentShuffledIndex], currentPatchUrl, protocols[currentShuffledIndex], req: req)
        
        
        let firstFoundedFileResponce = responceStatus.flatMap{ (status) -> Future<Response> in
            
            
            if status.code != 403 && status.code != 404 {
                //print ("Success: File founded! ", hosts[index], currentUrl, response.status.code)
                let mapTemplate = MapsList(name: "", mode: "", backgroundUrl: urls[currentShuffledIndex], backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 0, dpiSD: "", dpiHD: "", parameters: 0, description: "")
                
                let newUrl = self.urlPatchCreator.calculateTileURL(x, y, z, mapTemplate)
                 
                return self.output.redirectWithReferer(to: newUrl, referer: nil, with: req)
                
            } else if (index + 1) < hosts.count {
                //print ("Recursive find for next index: ", hosts[index], currentUrl, response.status.code)
                return self.findExistingMirrorNumber(index: index+1, hosts, ports, patchs, urls, protocols, x, y, z, order, req: req)
                
            } else {
                //print("Fail: All URLs checked and file not founded. ", response.status.code)
                return self.output.notFoundResponce(req)
            }
        }
        
        return firstFoundedFileResponce
    }
    
    
    
    
    
    public func checkUrlStatus(_ host: String, _ port: String, _ url: String, _ isHttps: Bool, req: Request) -> Future<HTTPResponseStatus> {
        
        let timeout = 500       //TODO: I need to increase this speed
        let defaultPort = 80
        var connection: EventLoopFuture<HTTPClient>

        // Connect to Host URL with correct port
        if port == "any" {
            if isHttps {
                connection = HTTPClient.connect(scheme: .https, hostname: host, on: req)
            } else {
                connection = HTTPClient.connect(hostname: host, on: req)
            }
            
        } else {
            let portNumber = Int(port) ?? defaultPort
            connection = HTTPClient.connect(hostname: host, port: portNumber, connectTimeout: .milliseconds(timeout), on: req)
        }
        
        
        // Synchronization: Waiting, while coonection will be started
        let responseStatus = connection.flatMap { client -> Future<HTTPResponseStatus> in
            
            let request = HTTPRequest(method: .HEAD, url: url)
            
            let response = client.send(request)
            
            let status = response.flatMap { res -> Future<HTTPResponseStatus> in
                
                //print(res.status.code, url)
                return req.future(res.status)
            }
            
            return status
            
        }.catchFlatMap { error in
            
            return req.future(HTTPResponseStatus(statusCode: 404))
        }
        
        return responseStatus
    }
    
    
    
    
    public func checkUrlStatusWithProxy(_ url: String, _ headers: HTTPHeaders?, _ body: LosslessHTTPBodyRepresentable?,  _ req: Request) throws -> Future<HTTPResponseStatus> {
        
        print("@@@ checkUrlStatusAndProxy 1 - Start ", url)
        
        guard URL(string: url) != nil else {
            let s = HTTPStatus(statusCode: 400, reasonPhrase: "Invalid url found in Recusive checkUrlStatusAndProxy checker")
            print("@@@ checkUrlStatusAndProxy 2 - error response ", url)
            return req.future(s)
        }
        
        var checkingResponse: Future<Response>
        
        if headers == nil || body == nil {
            print("@@@ checkUrlStatusAndProxy 3 - empty headers")
            
            checkingResponse = try req.client().get(url)
            
        } else {
            print("@@@ checkUrlStatusAndProxy 4 - not empty headers")
            let request = Request(http: HTTPRequest(method: .HEAD, url: url, headers: headers!, body: body!), using: req)
            
            checkingResponse = try req.client().send(request)
        }
        
        
        print("@@@ checkUrlStatusAndProxy 5 - after get")
        let responseStatus = checkingResponse.map(to: HTTPResponseStatus.self) { res in
            print("@@@ checkUrlStatusAndProxy 6 - status ", res.http.status)
            //print(res.http.status.code, url)
            return res.http.status
        }
        
        print("@@@ finish 7")
        return responseStatus
    }
    
    
}
