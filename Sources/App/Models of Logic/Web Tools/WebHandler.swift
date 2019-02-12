//
//  WebHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 31/12/2018.
//

import Foundation
import Vapor

class WebHandler {
    
    let sqlHandler = SQLHandler()
    let imageProcessor = ImageProcessor()
    let urlPatchCreator = URLPatchCreator()
    let paralleliser = FreeAccountsParalleliser()
    let coordinateTransformer = CoordinateTransformer()
    
    
    let output = OutputResponceGenerator()
    let urlChecker = UrlFIleChecker()
    
    init() {
        urlChecker.delegate = self
    }
    
    
    
    // MARK: Main function
    
    public func startSearchingForMap(_ mapName: String, xText:String, _ yText: String, _ zoom: Int, _ req: Request) throws -> Future<Response>  {
        
        // Load map informarion from database in Future format
        let mapData = try sqlHandler.getBy(mapName: mapName, req)
        
        // Generate Session mumber to use with multy channel processing
        let sessionID = paralleliser.splitByTime()
        
        
        // Synchronizing map information
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return self.output.notFoundResponce(req)}
            guard zoom >= mapObject.zoomMin else {return self.output.notFoundResponce(req)}
            
            
            
            // Select processing mode
            switch mapObject.mode {
                
            case "redirect":
                return try self.makeSimpleRedirectingResponse(mapObject, mapName, xText, yText, zoom, req)
                
            case "proxy":
                return try self.makeRedirectingWithProxyResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "overlay":
                return try self.makeOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "mapboxZoom":
                return try self.makeMapboxZoomRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "mapboxOverlay":
                return try self.makeMapboxOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "mapboxOverlayWithZoom":
                return try self.makeMapboxOverlayWithZoomRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "wgs84":
                return try self.makeWgs84RedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "wgs84_overlay":
                return try self.makeWgs84OverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "wgs84_double_overlay":
                return try self.makeWgs84DoubleOverlayRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "checkAllMirrors":
                return try self.makeMirrorCheckerRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            case "multyLayer":
                return try self.makeMultyLayerRedirectingResponse(mapObject, mapName, xText, yText, zoom, sessionID, req)
                
            default:
                return try self.output.errorResponce("Unknown value MapMode in data base", req)
            }
            
        }
        
        return responce
    }
    
    
    
    
    
    
    
    
    
    // MARK: Simple one-layer functions
    
    private func makeSimpleRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        return output.redirect(to: newUrl, with: req)
    }
    
    
    
    
    
    private func makeRedirectingWithProxyResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        let resultResponce = try urlChecker.checkUrlStatusAndProxy(newUrl, sessionID, req)
        
        return resultResponce
    }
    
    
    
    
    
    // MARK: Simple two-layer functions
    
    private func makeOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
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
                    let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], sessionID, req)
                    
                    // Redirect to URL of resulting file in image-processor storage
                    return self.imageProcessor.syncTwo(loadingResponces, req) { res in
                        
                        let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl, sessionID)
                        return self.output.redirect(to: newUrl, with: req)
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    // MARK: Mapbox transformation functions
    
    private func makeMapboxZoomRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        // Load layers info from data base in Future format
        let mapList = try self.sqlHandler.getMirrorsListBy(setName: mapName, req)
        
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
            
            let randomIndex = randomNubmerForHeroku(mapListData.count)
            
            let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, zoom, mapListData[randomIndex].url, "")
            
            let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, sessionID, req)
            
            // Get URL of resulting file in image-processor storage
            return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                
                let processedImageUrl = self.imageProcessor.getUrlWithZooming(fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, sessionID)
                
                return self.output.redirect(to: processedImageUrl, with: req)
                
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    private func makeMapboxOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
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
                    
                    let randomIndex = randomNubmerForHeroku(overObject.count)
                    
                    let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject[randomIndex].url, "")
                    
                    // Upload all images to online image-processor
                    let loadingResponces = try self.imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], sessionID, req)
                    
                    // Redirect to URL of resulting file in image-processor storage
                    return self.imageProcessor.syncTwo(loadingResponces, req) { res in
                        
                        let newUrl = self.imageProcessor.getUrlOverlay(baseUrl, overlayUrl, sessionID)
                        return self.output.redirect(to: newUrl, with: req)
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    private func makeMapboxOverlayWithZoomRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
                    
                    let randomIndex = randomNubmerForHeroku(overObject.count)
                    
                    let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                    
                    
                    // To make one image with offset I need four nearest to crop.
                    let fourTilesInNextZoomUrls = self.urlPatchCreator.calculateFourNextZoomTilesUrls(tileNumbers.x, tileNumbers.y, zoom, overObject[randomIndex].url, "")
                    
                    
                    
                    // Upload all images to online image-processor
                    let loadingBaseResponce = try self.imageProcessor.uploadOneTile(baseUrl, sessionID, req)
                    
                    let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourTilesInNextZoomUrls, sessionID, req)
                    
                    
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingOverResponces, req) { res1 in
                        
                        return self.imageProcessor.syncOne(loadingBaseResponce, req) { res2 in
                            
                            
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithZoomingAndOverlay(baseUrl, fourTilesInNextZoomUrls, tileNumbers.x, tileNumbers.y, sessionID)
                            
                            return self.output.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    // MARK: WGS-84 transformation functions
    
    private func makeWgs84RedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, zoom)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
        
        
        // To make image with offset I'm cropping one image from four nearest images.
        let fourTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        // Upload all images to online image-processor
        let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, sessionID, req)
        
        
        // Get URL of resulting file in image-processor storage
        let redirectingResponce = imageProcessor.syncFour(loadingResponces, req) { res in
            
            let processedImageUrl = self.imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY, sessionID)
            
            return self.output.redirect(to: processedImageUrl, with: req)
        }
        
        return redirectingResponce
    }
    
    
    
    
    private func makeWgs84OverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, sessionID, req)
                    
                    let loadingOverResponce = try self.imageProcessor.uploadOneTile(overlayUrl, sessionID, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        
                        return self.imageProcessor.syncOne(loadingOverResponce, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, overlayUrl, tileWGSPosition.offsetX, tileWGSPosition.offsetY, sessionID)
                            
                            return self.output.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    private func makeWgs84DoubleOverlayRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
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
                    let loadingResponces = try self.imageProcessor.uploadFourTiles(fourTilesAroundUrls, sessionID, req)
                    
                    let loadingOverResponces = try self.imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, sessionID, req)
                    
                    // Get URL of resulting file in image-processor storage
                    return self.imageProcessor.syncFour(loadingResponces, req) { res1 in
                        return self.imageProcessor.syncFour(loadingOverResponces, req) { res2 in
                            
                            let processedImageUrl = self.imageProcessor.getUrlWithOffsetAndDoubleOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY, sessionID)
                            
                            return self.output.redirect(to: processedImageUrl, with: req)
                        }
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
    
    
    
    
    // MARK: Url checking multy layer functions

    private func makeMirrorCheckerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
        
        let redirectingResponce = try urlChecker.checkMirrorsList(mapName, tileNumbers.x, tileNumbers.y, zoom, req)
        
        return redirectingResponce
    }
    
    
    
    
    private func makeMultyLayerRedirectingResponse(_ mapObject: (MapsList), _ mapName:String, _ xText: String, _ yText: String, _ zoom: Int, _ sessionID: String, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
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
