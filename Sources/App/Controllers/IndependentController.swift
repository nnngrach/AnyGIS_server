//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor
import Foundation

class IndependentController {
    
    let urlTransformer = UrlTransformer()
    
    
    func calculateTileURL(_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapData) -> String {
        
        var result = mapObject.backgroundUrl
        let serverName = mapObject.backgroundServerName
        let coordinates = [x, y, z]
        
        for i in 0 ..< urlTransformer.urlPlaceholders.count {
            let replacedText = urlTransformer.urlPlaceholders[i]
            let transformerClosure = urlTransformer.urlTransformers[i]
            
            if result.contains(replacedText) {
                let newText = transformerClosure(coordinates, serverName, urlTransformer)
                result = result.replacingOccurrences(of: replacedText, with: newText)
                
            } else {
                continue
            }
        }
        
        return result
    }
    
}
