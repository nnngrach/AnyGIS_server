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
        
        result = replace("{x}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getX)
        
        result = replace("{y}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getY)
        
        result = replace("{z}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getZ)
        
        result = replace("{s}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getS)
        
        result = replace("{googleZ}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getGoogleZ)
        
        result = replace("{invY}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getInvY)
        
        result = replace("{sasZ}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getSasZ)
        
        result = replace("{folderX}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getFolderX)
        
        result = replace("{folderY}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getFolderY)
        
        result = replace("{yandexX}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getX)
        
        result = replace("{yandexY}", in: result, coordinates: coordinates, serverNumber: serverName, with: coordinateTransformer.getY)
        
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
