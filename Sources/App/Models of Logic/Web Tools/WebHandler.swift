//
//  WebHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 31/12/2018.
//

import Foundation
import Vapor

class WebHandler {
    
    let sqlHandler = SQLHandler()
    let stravaParser = StravaParser()
    let imageProcessor = ImageProcessor()
    let urlPatchCreator = URLPatchCreator()
    let paralleliser = FreeAccountsParalleliser()
    let coordinateTransformer = CoordinateTransformer()
    
    let processorRedirect = MapProcessorRedirect()
    let processorReferer = MapProcessorReferer()
    let processorProxy = MapProcessorProxy()
    let processorOverlay = MapProcessorOverlay()
    let processorMapboxZoom = MapProcessorMapboxZoom()
    let processorMapboxOverlay = MapProcessorMapboxOverlay()
    
    
    
    let output = OutputResponceGenerator()
    let urlChecker = UrlFIleChecker()
    
    init() {
        urlChecker.delegate = self
    }
    
    
    
    // MARK: Main function
    
    public func startSearchingForMap(_ mapName: String, xText:String, _ yText: String, _ zoom: Int, _ req: Request) throws -> Future<Response>  {
        
        // Load map informarion from database in Future format
        let mapData = try sqlHandler.getBy(mapName: mapName, req)
        
        
        // Synchronizing map information
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return self.output.notFoundResponce(req)}
            guard zoom >= mapObject.zoomMin else {return self.output.notFoundResponce(req)}
            
            let tileNumbers = try self.coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
            
            // Generate Session mumber to use with multy channel processing
            let cloudinarySessionId = try self.paralleliser.getCloudinarySessionId(req)
            let mapboxSessionId = self.paralleliser.getMapboxSessionId()
            
            
            
            
            
            // Select processing mode
            switch mapObject.mode {
                
            case "redirect":
                return try self.processorRedirect.process(mapName, tileNumbers, mapObject, req)
                
            case "loadWithReferer":
                return try self.processorReferer.process(mapName, tileNumbers, mapObject, req)
                
            case "proxy":
                return try self.processorProxy.process(mapName, tileNumbers, mapObject, req)
                
            case "overlay":
                return try self.processorOverlay.process(mapName, tileNumbers, mapObject, req)
                
            case "mapboxZoom":
                return try self.processorMapboxZoom.process(mapName, tileNumbers, mapObject, req)
                
            case "mapboxOverlay":
                return try self.processorMapboxOverlay.process(mapName, tileNumbers, mapObject, req)
                
                
            case "mapboxOverlayWithZoom":
                return try self.makeMapboxOverlayWithZoomRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, mapboxSessionId, req)
                
            case "navionics":
                return try self.makeNavisonicRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "wgs84":
                return try self.makeWgs84RedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
            case "wgs84_overlay":
                return try self.makeWgs84OverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
            case "wgs84_double_overlay":
                return try self.makeWgs84DoubleOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
            case "strava":
                return try self.makeStravaRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
                
            case "checkAllMirrors":
                return try self.makeMirrorCheckerRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
            case "multyLayer":
                return try self.makeMultyLayerRedirectingResponse(mapObject, mapName, xText, yText, zoom, cloudinarySessionId, req)
                
            default:
                return try self.output.serverErrorResponce("Unknown value MapMode in data base", req)
            }
            
        }
        
        return responce
    }
    
    
    
    
    
    
    
    
    
    // MARK: Simple one-layer functions
  
    /*
    private func makeSimpleRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ req: Request) throws -> EventLoopFuture<Response> {
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        return output.redirect(to: newUrl, with: req)
    }
 */
    
    
    
    
    /*
    private func makeLoadWithRefererResponse(_ mapObject: (MapsList), _ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ req: Request) throws -> EventLoopFuture<Response> {
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        let userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.110 Safari/537.36"
       
        let headers = HTTPHeaders([("referer", mapObject.referer), ("User-Agent", userAgent)])
        
        return try req.client().get(newUrl, headers: headers)
    }
    */
    
    
    
    /*
    private func makeRedirectingWithProxyResponse(_ mapObject: (MapsList), _ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        
        return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
        
            let checkedStatus = try self.urlChecker.checkUrlStatusAndProxy(newUrl, nil, nil, req)
            
            let resultResponse = checkedStatus.map(to: Response.self) { status in
                
                var url = ""
                
                if status.code == 200 {
                    url = newUrl
                } else {
                    url = self.imageProcessor.getDirectUrl(url, cloudinaryID)
                }
                
                return req.redirect(to: url)
            }
            
            return resultResponse
        }
        
    }
    */
    
    
    
    
    // MARK: Simple two-layer functions
    
    /*
    private func makeOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
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
                    return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                    
                    
                    let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], cloudinaryID, req)
                    
                    // Redirect to URL of resulting file in image-processor storage
                    return self.imageProcessor.syncTwo(loadingResponces, req) { res in
                        
                        let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl, cloudinaryID)
                        return self.output.redirect(to: newUrl, with: req)
                        
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    */
    
    
    
    
    // MARK: Mapbox transformation functions
    
    /*
    private func makeMapboxZoomRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ mapboxSessionId: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load layers info from data base in Future format
        let mapList = try self.sqlHandler.getMirrorsListBy(setName: mapName, req)
        
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
            return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                
                let mapboxIndex = Int(mapboxSessionId) ?? 0
                
                let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, zoom, mapListData[mapboxIndex].url, "")
                
                let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, cloudinaryID, req)
                
                // Get URL of resulting file in image-processor storage
                return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                    
                    let processedImageUrl = self.imageProcessor.getUrlWithZooming(fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, cloudinaryID)
                    
                    return self.output.redirect(to: processedImageUrl, with: req)
                    
                }
            }
        }
        
        return redirectingResponce
    }
    */
    
    
    
    
    private func makeMapboxOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ mapboxSessionId: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
            let overlayMapsData = try self.sqlHandler.getMirrorsListBy(setName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapsData.flatMap(to: Response.self) { overObject  in
                    return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                    
                    let index = Int(mapboxSessionId) ?? 0
                    
                    let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject[index].url, "")
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], cloudinaryID, req)
                    
                    // Redirect to URL of resulting file in image-processor storage
                    return self.imageProcessor.syncTwo(loadingResponces, req) { res in
                        
                        let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl, cloudinaryID)
                        return self.output.redirect(to: newUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    private func makeMapboxOverlayWithZoomRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ mapboxSessionId: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load layers info from data base in Future format
        let mapList = try sqlHandler.getOverlayBy(setName: mapName, req)
        
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
            
            // Load info for every layers from data base in Future format
            let baseMapName = mapListData.baseName
            let overlayMapName = mapListData.overlayName
            let baseMapData = try self.sqlHandler.getBy(mapName: baseMapName, req)
            let overlayMapData = try self.sqlHandler.getMirrorsListBy(setName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapData.flatMap(to: Response.self) { overObject  in
                    return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                    
                        let index = Int(mapboxSessionId) ?? 0
                        
                        let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                        
                        
                        // To make one image with offset I need four nearest to crop.
                        let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, zoom, overObject[index].url, "")
                        
                        
                        
                        // Upload all images to online image-processor
                        let loadingBaseResponce = try self.imageProcessor.uploadOneTile(baseUrl, cloudinaryID, req)
                        
                        let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, cloudinaryID, req)
                        
                        
                        
                        // Get URL of resulting file in image-processor storage
                        return self.imageProcessor.syncFour(loadingOverResponces, req) { res1 in
                            
                            return self.imageProcessor.syncOne(loadingBaseResponce, req) { res2 in
                                
                                
                                
                                let processedImageUrl = self.imageProcessor.getUrlWithZoomingAndOverlay(baseUrl, fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, cloudinaryID)
                                
                                return self.output.redirect(to: processedImageUrl, with: req)
                            }
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    

    
    
    
    // MARK: Navionics
    
    private func makeNavisonicRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let tileUrlBase = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        

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
    
    
    
    // MARK: WGS-84 transformation functions
    
    private func makeWgs84RedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, zoom)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
        
        
        return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
        
            // To make image with offset I'm cropping one image from four nearest images.
            let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
            // Upload all images to online image-processor
            let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, cloudinaryID, req)
        
        
            // Get URL of resulting file in image-processor storage
            let redirectingResponce = self.imageProcessor.syncFour(loadingResponces, req) { res in
                
                //print(fourTilesAroundUrls)
                
                let processedImageUrl = self.imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY, cloudinaryID)
                
                //print(processedImageUrl)
                
                return self.output.redirect(to: processedImageUrl, with: req)
            }
        
            return redirectingResponce
            
        }
    }
    
    
    
    
    private func makeWgs84OverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
                    return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                    
                    
                    // To make one image with offset I need four nearest to crop.
                    let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tileWGSPosition.x, tileWGSPosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileOSMNumbers.x, tileOSMNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, cloudinaryID, req)
                    
                    let loadingOverResponce = try self.imageProcessor.uploadOneTile(overlayUrl, cloudinaryID, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        
                        return self.imageProcessor.syncOne(loadingOverResponce, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, overlayUrl, tileWGSPosition.offsetX, tileWGSPosition.offsetY, cloudinaryID)
                            
                            return self.output.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    private func makeWgs84DoubleOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
                    return cloudinarySessionID.flatMap(to: Response.self) { cloudinaryID  in
                    
                    // To make one image with offset I need four nearest to crop.
                    let fourTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let fourOverTilesAroundUrls = self.urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, cloudinaryID, req)
                    
                    let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, cloudinaryID, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        return self.imageProcessor.syncFour(loadingOverResponces, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndDoubleOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY, cloudinaryID)
                            
                            return self.output.redirect(to: processedImageUrl, with: req)
                        }
                    }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    
    // MARK: Strava
    
    private func makeStravaRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let isInAuthProcessingStausText = "The app is processing Strava authorization. Please reload this map after 2 minutes"
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        var generatedUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        let storedStravaAuthData = try sqlHandler.getServiceDataBy(serviceName: "Strava", req)

        var futureUrl: Future<String> = req.future("")
        
        
        
        let resultResponse = storedStravaAuthData.flatMap(to: Response.self) { data in
            
            let storedStravaAuthLine = data[0]
            
            
            // Final URL as a future
            futureUrl = futureUrl.flatMap(to: String.self) {_ in
                
                // Load free version of map (/tiles/)
                if zoom < 12 {
                    
                    generatedUrl = generatedUrl.replacingOccurrences(of: "tiles-auth", with: "tiles")
                    
                    return req.future(generatedUrl)
                
                    
                // Load map with auth parameters (/tiles-auth/)
                } else {
                    
                    // Stop if is in auth processing now
                    guard storedStravaAuthLine.apiSecret != isInAuthProcessingStausText else {return req.future(isInAuthProcessingStausText)}
                    
                    
                    let urlWithStoredAuthKey = generatedUrl + storedStravaAuthLine.apiSecret
                    
                    let checkedStatus = try self.urlChecker.checkUrlStatusAndProxy(urlWithStoredAuthKey, nil, nil, req)
                    
                    
                    // Checking stored AuthKey
                    let futureUrlWithWorkingAuthKey = checkedStatus.flatMap(to: String.self) { status in
                        
                        // Key is valid. Return the same URL
                        if status.code == 200 {
                            
                            return req.future(urlWithStoredAuthKey)
                        
                        // Key is invalid. Fetching new key. Return URL with new key
                        } else {
                            
                            // Add stopper-flag
                            storedStravaAuthLine.apiSecret = isInAuthProcessingStausText
                            storedStravaAuthLine.save(on: req)
                            
                            
                            let stravaAuthParams = try self.stravaParser.getAuthParameters(login: storedStravaAuthLine.userName, password: storedStravaAuthLine.apiKey, req)
                            
                            let futureUrlWithNewAuthKey = stravaAuthParams.map(to: String.self) { newParams in
                                
                                storedStravaAuthLine.apiSecret = newParams
                                storedStravaAuthLine.save(on: req)
                                
                                return generatedUrl + newParams
                            }
                            
                            return futureUrlWithNewAuthKey
                        }
                    }
                    
                    return futureUrlWithWorkingAuthKey
                }
            }
            
            
            // Redirecting user to checked URL
            let response = futureUrl.map(to: Response.self){ resultUrl in
                
                guard resultUrl != isInAuthProcessingStausText else {return self.output.customErrorResponce(501, isInAuthProcessingStausText, req)}
                
                return req.redirect(to: resultUrl)
            }
            
            return response
        }
        
        
        return resultResponse
    }
    
    
    
    
    
    
    
    
    
    // MARK: Url checking multy layer functions

    private func makeMirrorCheckerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let redirectingResponce = try urlChecker.checkMirrorsList(mapName, tileNumbers.x, tileNumbers.y, zoom, req)
        
        return redirectingResponce
        //return try req.client().get(newUrl, headers: HTTPHeaders(dictionaryLiteral: ("referer",mapObject.referer)))
    }
    
    
    
    
    private func makeMultyLayerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ cloudinarySessionID: Future<String>, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load info for every layers from data base in Future format
        let layersList = try sqlHandler.getPriorityListBy(setName: mapName, zoom: zoom, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = layersList.flatMap(to: Response.self) { layersListData  in
            
            guard layersListData.count != 0 else {return self.output.notFoundResponce(req)}
            
            // Start checking of file existing for all layers URLs
            let startIndex = 0
            
            let firstExistingUrlResponse = try self.urlChecker.checkMultyLayerList(layersListData, startIndex, tileNumbers.x, tileNumbers.y, zoom, req)
            
            return firstExistingUrlResponse
        }
        
        return redirectingResponce
    }
    
    
}




extension WebHandler: WebHandlerDelegate {}
