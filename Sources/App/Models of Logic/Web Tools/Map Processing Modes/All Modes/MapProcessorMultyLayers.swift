//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorMultyLayers: AbstractMapProcessorSimple {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        
        // Load info for every layers from data base in Future format
        let layersList = try sqlHandler.getPriorityListBy(setName: mapName, zoom: tileNumbers.z, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = layersList.flatMap(to: Response.self) { layersListData  in
            
            guard layersListData.count != 0 else {return self.output.notFoundResponce(req)}
            
            // Start checking of file existing for all layers URLs
            let startIndex = 0
            
            let firstExistingUrlResponse = try self.urlChecker.checkMultyLayerList(layersListData, startIndex, tileNumbers.x, tileNumbers.y, tileNumbers.z, req)
            
            return firstExistingUrlResponse
        }
        
        return redirectingResponce
    }
    
}

