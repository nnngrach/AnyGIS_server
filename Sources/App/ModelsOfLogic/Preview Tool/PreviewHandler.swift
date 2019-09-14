//
//  PreviewHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 14/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor
import Foundation

class PreviewHandler {
    
    let baseHandler = SQLHandler()
    
    
    func generateLinkFor(mapName: String, req: Request) throws -> String {
        
        let data = try baseHandler.getCoordinatesDataBy(name: mapName, req)
        
        print(data)
        
        return ""
    }
    
}
