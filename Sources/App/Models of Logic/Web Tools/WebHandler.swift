//
//  WebHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 31/12/2018.
//

import Vapor

class WebHandler {
    
    let sqlHandler = SQLHandler()
    let imageProcessor = ImageProcessor()
    let urlPatchCreator = URLPatchCreator()
    let coordinateTransformer = CoordinateTransformer()
    
    
    
    // MARK: Main function
    
    public func startSearchingForMap(_ mapName: String, xText:String, _ yText: String, _ zoom: Int, _ req: Request) throws -> Future<Response>  {
        
        // Load map informarion from database in Future format
        let mapData = try sqlHandler.getBy(mapName: mapName, req)
        
        
        // Synchronizing map information
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return self.notFoundResponce(req)}
            guard zoom >= mapObject.zoomMin else {return self.notFoundResponce(req)}
            
            
            // Select processing mode
            switch mapObject.mode {
                
            case "redirect":
                return try self.makeSimpleRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "overlay":
                return try self.makeOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "wgs84":
                return try self.makeWgs84RedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "wgs84_overlay":
                return try self.makeWgs84OverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "wgs84_double_overlay":
                return try self.makeWgs84DoubleOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "checkAllMirrors":
                return try self.makeMirrorCheckerRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "multyLayer":
                return try self.makeMultyLayerRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            default:
                return self.errorResponce("Unknown value MapMode in data base", req)
            }
            
        }
        
        return responce
    }
    
    
    
    
    
    
    
    // MARK: Make Redirecting Response
    
    private func makeSimpleRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        return redirect(to: newUrl, with: req)
    }
    
    
    
    
    
    private func makeOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load layers info from data base in Future format
        let layers = try sqlHandler.getOverlayBy(setName: mapName, req)
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = layers.flatMap(to: Response.self) { layersData  in
            
            // Load info for every layers from data base in Future format
            let baseMapName = layersData.baseName
            let overlayMapName = layersData.overlayName
            let baseMapData = try self.sqlHandler.getBy(mapName: baseMapName, req)
            let overlayMapData = try self.sqlHandler.getBy(mapName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapData.flatMap(to: Response.self) { overObject  in
                    
                    let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], req)
                    
                    // Redirect to URL of resulting file in image-processor storage
                    return self.imageProcessor.syncTwo(loadingResponces, req) { res in
                        
                        let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl)
                        return self.redirect(to: newUrl, with: req)
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    private func makeWgs84RedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, zoom)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
        
        
        // To make image with offset I'm cropping one image from four nearest images.
        let fourTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        // Upload all images to online image-processor
        let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, req)
        
        
        // Get URL of resulting file in image-processor storage
        let redirectingResponce = imageProcessor.syncFour(loadingResponces, req) { res in
            
            let processedImageUrl = self.imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
            
            return self.redirect(to: processedImageUrl, with: req)
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    
    private func makeWgs84OverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, zoom)
        
        let tileWGSPosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
        
        let tileOSMNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        
        // Load layers info from data base in Future format
        let mapList = try sqlHandler.getOverlayBy(setName: mapName, req)
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
            
            // Load info for every layers from data base in Future format
            let baseMapName = mapListData.baseName
            let overlayMapName = mapListData.overlayName
            let baseMapData = try self.sqlHandler.getBy(mapName: baseMapName, req)
            let overlayMapData = try self.sqlHandler.getBy(mapName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapData.flatMap(to: Response.self) { overObject  in
                    
                    // To make one image with offset I need four nearest to crop.
                    let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tileWGSPosition.x, tileWGSPosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileOSMNumbers.x, tileOSMNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    print(overlayUrl)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, req)
                    
                    let loadingOverResponce = try self.imageProcessor.uploadOneTile(overlayUrl, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        
                        return self.imageProcessor.syncOne(loadingOverResponce, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, overlayUrl, tileWGSPosition.offsetX, tileWGSPosition.offsetY)
                            
                            return self.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    private func makeWgs84DoubleOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, zoom)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
        
        // Load layers info from data base in Future format
        let mapList = try sqlHandler.getOverlayBy(setName: mapName, req)
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
            
            // Load info for every layers from data base in Future format
            let baseMapName = mapListData.baseName
            let overlayMapName = mapListData.overlayName
            let baseMapData = try self.sqlHandler.getBy(mapName: baseMapName, req)
            let overlayMapData = try self.sqlHandler.getBy(mapName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapData.flatMap(to: Response.self) { overObject  in
                    
                    // To make one image with offset I need four nearest to crop.
                    let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let fourOverTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, req)
                    
                    let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        return self.imageProcessor.syncFour(loadingOverResponces, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndDoubleOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                            
                            return self.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    

    
    
    private func makeMirrorCheckerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let redirectingResponce = try checkMirrorsList(mapName, tileNumbers.x, tileNumbers.y, zoom, req)
        
        return redirectingResponce
    }
    
    
    
    
    
    
    private func makeMultyLayerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load info for every layers from data base in Future format
        let layersList = try sqlHandler.getPriorityListBy(setName: mapName, zoom: zoom, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = layersList.flatMap(to: Response.self) { layersListData  in
            
            guard layersListData.count != 0 else {return self.notFoundResponce(req)}
            
            // Start checking of file existing for all layers URLs
            let startIndex = 0
            
            let firstExistingUrlResponse = try self.checkMultyLayerList(layersListData, startIndex, tileNumbers.x, tileNumbers.y, zoom, req)
            
            return firstExistingUrlResponse
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    
    
    
    
    // MARK: Recursive checkers for file existing by URL
    
    // Checker for MultyLayer mode
    private func checkMultyLayerList(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        let currentMapName = maps[index].mapName
        
        // Quick redirect for maps with global coverage
        guard !maps[index].notChecking else {
            return try startSearchingForMap(currentMapName, xText: String(x), String(y), z, req)
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
        
        redirectingResponse = response.flatMap(to: Response.self) { res in
            
            if (res.http.status.code == 404) && (maps.count > index+1) {
                // print("Recursive find next ")
                return try self.checkMultyLayerList(maps, index+1, x, y, z, req)
                
            } else if(res.http.status.code == 404) {
                // print("Fail ")
                return self.notFoundResponce(req)
                
            } else {
                // print("Success ")
                return req.future(res)
            }
        }
        
        return redirectingResponse
    }
    
    
    
    
    // Checker for Mirrors mode
    private func checkMirrorsList(_ mirrorName: String, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        // Load info for every mirrors from data base in Future format
        let mirrorsList = try sqlHandler.getMirrorsListBy(setName: mirrorName, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = mirrorsList.flatMap(to: Response.self) { mirrorsListData  in
            
            guard mirrorsListData.count != 0 else {return self.notFoundResponce(req)}
            
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
                
                firstFoundedUrlResponse = self.redirect(to: newUrl, with: req)
                
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
        
        guard let currentShuffledIndex = order[index] else {return notFoundResponce(req)}
        
        let timeout = 350
        let defaultPort = 8080
        var connection: EventLoopFuture<HTTPClient>
        
        // Connect to Host URL with correct port
        if ports[currentShuffledIndex] == "any" {
            connection = HTTPClient.connect(hostname: hosts[currentShuffledIndex], on: req)
        } else {
            let portNumber = Int(ports[currentShuffledIndex]) ?? defaultPort
            connection = HTTPClient.connect(hostname: hosts[currentShuffledIndex], port: portNumber, connectTimeout: .milliseconds(timeout), on: req)
        }
        
        // Synchronization: Waiting, while coonection will be started
        let firstFoundedFileIndex = connection.flatMap { (client) -> Future<Response> in
            
            // Generate URL and make Request for it
            let currentUrl = self.urlPatchCreator.calculateTileURL(x, y, z, patchs[currentShuffledIndex], "")
            
            let request = HTTPRequest(method: .HEAD, url: currentUrl)
            
            
            // Send Request and check HTML status code
            // Return index of founded file if success.
            return client.send(request).flatMap{ (response) -> Future<Response> in
                
                if response.status.code != 404 {
                    //print ("Success: File founded! ", hosts[shuffledIndex], currentUrl)
                    let newUrl = self.urlPatchCreator.calculateTileURL(x, y, z, urls[currentShuffledIndex], "")
                    return self.redirect(to: newUrl, with: req)
                    
                } else if (index + 1) < hosts.count {
                    //print ("Recursive find for next index: ", hosts[shuffledIndex], currentUrl)
                    return self.findExistingMirrorNumber(index: index+1, hosts, ports, patchs, urls, x, y, z, order, req: req)
                    
                } else {
                    //print("Fail: All URLs checked and file not founded.")
                    return self.notFoundResponce(req)
                }
            }
        }
        
        return firstFoundedFileIndex
    }
    
    
    
    
    
    
    // MARK: Simple Html functions
    
    private func errorResponce (_ description: String, _ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: description), body: "")).encode(for: req)
    }
    
    
    private func notFoundResponce (_ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .notFound, body: "")).encode(for: req)
    }
    
    
    private func redirect(to url: String, with req: Request) -> Future<Response>  {
        return try! req.redirect(to: url).encode(for: req)
    }
    
}
