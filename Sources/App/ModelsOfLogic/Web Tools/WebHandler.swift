//
//  WebHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 31/12/2018.
//

import Vapor

class WebHandler {
    
    let coordinateTransformer = CoordinateTransformer()
    let output = OutputResponceGenerator()
    let sqlHandler = SQLHandler()

    let processorRedirect = MapProcessorRedirect()
    let processorReferer = MapProcessorReferer()
    let processorProxy = MapProcessorProxy()
    let processorProxyUpload = MapProcessorProxyUpload()
    let processorOpacity = MapProcessorOpacity()
    let processorOverlay = MapProcessorOverlay()
    let processorText = MapProcessorText()
    let processorMapboxZoom = MapProcessorMapboxZoom()
    let processorMapboxOverlay = MapProcessorMapboxOverlay()
    let processorMapboxOverlayWithZoom = MapProcessorMapboxOverlayWithZoom()
    let processorNavionics = MapProcessorNavionics()
    let processorWgs84 = MapProcessorWgs84()
    let processorWgs84Overlay = MapProcessorWgs84Overlay()
    let processorWgs84DoubleOverlay = MapProcessorWgs84DoubleOverlay()
    let processorStrava = MapProcessorStrava()
    let processorMirrors = MapProcessorMirrors()
    let processorMultyLayers = MapProcessorMultyLayers()
    
    
    init() {
        processorMultyLayers.urlChecker.delegate = self
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
            
            
            
            // Select processing mode
            switch mapObject.mode {
                
            case "redirect":
                return try self.processorRedirect.process(mapName, tileNumbers, mapObject, req)
                
            case "loadWithReferer":
                return try self.processorReferer.process(mapName, tileNumbers, mapObject, req)
                
            case "proxy":
                return try self.processorProxy.process(mapName, tileNumbers, mapObject, req)
                
            case "proxyUpload":
                return try self.processorProxyUpload.process(mapName, tileNumbers, mapObject, req)
                
            case "opacity":
                return try self.processorOpacity.process(mapName, tileNumbers, mapObject, req)
                
            case "overlay":
                return try self.processorOverlay.process(mapName, tileNumbers, mapObject, req)
                
            case "text":
                return try self.processorText.process(mapName, tileNumbers, mapObject, req)
                
            case "mapboxZoom":
                return try self.processorMapboxZoom.process(mapName, tileNumbers, mapObject, req)
                
            case "mapboxOverlay":
                return try self.processorMapboxOverlay.process(mapName, tileNumbers, mapObject, req)
                
            case "mapboxOverlayWithZoom":
                return try self.processorMapboxOverlayWithZoom.process(mapName, tileNumbers, mapObject, req)
                
            case "navionics":
                return try self.processorNavionics.process(mapName, tileNumbers, mapObject, req)
                
            case "wgs84":
                return try self.processorWgs84.process(mapName, tileNumbers, mapObject, req)

                
            case "wgs84_overlay":
                return try self.processorWgs84Overlay.process(mapName, tileNumbers, mapObject, req)
                
            case "wgs84_double_overlay":
                return try self.processorWgs84DoubleOverlay.process(mapName, tileNumbers, mapObject, req)
                
            case "strava":
                return try self.processorStrava.process(mapName, tileNumbers, mapObject, req)
                
                
            case "checkAllMirrors":
                return try self.processorMirrors.process(mapName, tileNumbers, mapObject, req)
                
            case "multyLayer":
                return try self.processorMultyLayers.process(mapName, tileNumbers, mapObject, req)
                
            default:
                return try self.output.serverErrorResponce("Unknown value MapMode in data base", req)
            }
            
        }
        
        return responce
    }
    
}


extension WebHandler: WebHandlerDelegate {}
