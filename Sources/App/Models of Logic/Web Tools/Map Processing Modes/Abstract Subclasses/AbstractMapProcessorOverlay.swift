//
//  AbstractMapProcessorSimple.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class AbstractMapProcessorOverlay: AbstractMapProcessorSimple  {
    
    
    override func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int),  _ mapObject: (MapsList), _ req: Request) throws -> Future<Response> {
        
        // Load layers info from data base in Future format
        let layers = try sqlHandler.getOverlayBy(setName: mapName, req)
        
        let futureCloudinaryId = try self.paralleliser.getCloudinarySessionId(req)
        
        
        // Synchronization Futrure to data object.
        // Generating redirect URL-response to processed image.
        return layers.flatMap(to: Response.self) { layersData  in
            
            // Load info for every layers from data base in Future format
            let baseMapName = layersData.baseName
            let overlayMapName = layersData.overlayName
            let baseMapData = try self.sqlHandler.getBy(mapName: baseMapName, req)
            let overlayMapData = try self.sqlHandler.getBy(mapName: overlayMapName, req)
            
            
            // Synchronization Futrure to data object.
            return baseMapData.flatMap(to: Response.self) { baseObject  in
                return overlayMapData.flatMap(to: Response.self) { overlayObject  in
                    return futureCloudinaryId.flatMap(to: Response.self) { cloudinaryId  in
                        
                        return try self.makeCustomActions(mapName, tileNumbers, nil, mapObject, baseObject, overlayObject, cloudinaryId, req)
                    }
                }
            }
        }
    }
    
    
}
