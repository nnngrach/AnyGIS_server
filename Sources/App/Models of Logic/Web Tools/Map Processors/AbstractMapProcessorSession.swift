//
//  AbstractMapProcessorSimple.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class AbstractMapProcessorSession: AbstractMapProcessorSimple  {
    
    let paralleliser = FreeAccountsParalleliser()
    let imageProcessor = ImageProcessor()
    
    override func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int),  _ mapObject: (MapsList), _ req: Request) throws -> Future<Response> {
        
        let futureCloudinaryId = try self.paralleliser.getCloudinarySessionId(req)

        return try futureCloudinaryId.flatMap { cloudinarySessionId -> Future<Response> in
            return try self.makeCustomActions(mapName, tileNumbers, mapObject, cloudinarySessionId, nil, req)
        }
    }
    
}
