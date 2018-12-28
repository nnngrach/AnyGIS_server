//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor
import Foundation

class IndependentController {
    
    let baseHandler = BaseHandler()
    let coordinateTransformer = CoordinateTransformer()
    let imageProcessor = ImageProcessor()
    
    
    func findTile(_ x: Int, _ y: Int, _ z: Int,  _ mapObject: MapData) -> String {
        
        var result = mapObject.backgroundUrl
        let serverName = mapObject.backgroundServerName
        let coordinates = [x, y, z]
        
        
        for i in 0 ..< coordinateTransformer.urlPlaceholders.count {
            result = replace(coordinateTransformer.urlPlaceholders[i],
                             in: result,
                             coordinates: coordinates,
                             serverNumber: serverName,
                             with: coordinateTransformer.urlTransformers[i](coordinateTransformer))
        }
        
        
        return result
    }
    

    
    
    func replace(_ replacedText: String, in url: String, coordinates: [Int], serverNumber: String, with closure: @escaping ([Int], String) -> String) -> String {
        
        if url.contains(replacedText) {
            let newText = closure(coordinates, serverNumber)
            return url.replacingOccurrences(of: replacedText, with: newText)
        } else {
            return url
        }
    }
    

    
}
