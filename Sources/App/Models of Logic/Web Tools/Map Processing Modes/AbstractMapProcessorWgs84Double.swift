//
//  AbstractMapProcessorWgs84.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//

import Vapor

class AbstractMapProcessorWgs84Double: AbstractMapProcessorSimple  {
    
    
    override func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int),  _ mapObject: (MapsList), _ req: Request) throws -> Future<Response> {
        
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, tileNumbers.z)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: tileNumbers.z)
        
        let futureCloudinaryId = try self.paralleliser.getCloudinarySessionId(req)
        
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
                    return futureCloudinaryId.flatMap(to: Response.self) { cloudinarySessionId  in
                        
                        return try self.makeCustomActions(mapName, tileNumbers, tilePosition, mapObject, nil, nil, cloudinarySessionId, nil, req)
                        
                    }
                }
            }
        }
        
        return redirectingResponce
    }
    
}
