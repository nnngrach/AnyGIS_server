//
//  AbstractMapProcessorWgs84.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//

import Vapor

class AbstractMapProcessorWgs84: AbstractMapProcessorSimple  {
    
    
    override func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int),  _ mapObject: (MapsList), _ req: Request) throws -> Future<Response> {
        
        let coordinates = coordinateTransformer.tileNumberToCoordinates(tileNumbers.x, tileNumbers.y, tileNumbers.z)
        
        let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: tileNumbers.z)
        
        let futureCloudinaryId = try self.paralleliser.getCloudinarySessionId(req)
        
        
        return futureCloudinaryId.flatMap(to: Response.self) { cloudinarySessionId  in
            
            return try self.makeCustomActions(mapName, tileNumbers, tilePosition, mapObject, nil, nil, cloudinarySessionId, req)
        }
    }
    
}
