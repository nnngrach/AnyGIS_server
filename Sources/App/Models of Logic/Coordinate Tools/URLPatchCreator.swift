//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor


class URLPatchCreator {
    
    
    public func calculateTileURL(_ x: Int, _ y: Int, _ z: Int, _ url:String, _ serverName:String) -> String {
        
        var result = url
        let coordinates = [x, y, z]
        
        for i in 0 ..< urlPlaceholders.count {
            let replacedText = urlPlaceholders[i]
            let transformerClosure = urlTransformers[i]
            
            if result.contains(replacedText) {
                let newText = transformerClosure(coordinates, serverName)
                result = result.replacingOccurrences(of: replacedText, with: newText)
                
            } else {
                continue
            }
        }
        
        return result
    }
    
    
    
    public func calculateFourTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ url:String, _ serverName:String) -> [String] {
        let topLeftTileUrl = calculateTileURL(x, y, z, url, serverName)
        let topRightTileUrl = calculateTileURL(x+1, y, z, url, serverName)
        let bottomRightTileUrl = calculateTileURL(x+1, y+1, z, url, serverName)
        let bottomLeftTileUrl = calculateTileURL(x, y+1, z, url, serverName)
        
        return [topLeftTileUrl, topRightTileUrl, bottomRightTileUrl, bottomLeftTileUrl]
    }
    
    
    
    
    
    // All URL replacing functions
    // (I can't call any functions of this class from closures)
    // ("self" does't works. So i using dependency injection)
    
    private let getX: ([Int], String) -> String = {
        coordinates, serverName in
        
        return "\(coordinates[0])"
    }
    
    
    private let getY: ([Int], String) -> String = {
        coordinates, serverName in
        
        return "\(coordinates[1])"
    }
    
    
    private let getZ: ([Int], String) -> String = {
        coordinates, serverName in
        
        return "\(coordinates[2])"
    }
    
    
    private let getS: ([Int], String) -> String = {
        coordinates, serverName in
        
        switch serverName {
        case "wikimapia":
            let result = ((coordinates[0]%4) + (coordinates[1]%4)*4)
            return "\(result)"
            
        case "sasPlanet":
            return "http://91.237.82.95:8088/"
            
        default:
            let serverLetters = Array(serverName)
            let randomNumber = randomNubmerForHeroku(serverLetters.count)
            return String(serverLetters[randomNumber])
        }
    }
    
    
    private let getGoogleZ: ([Int], String) -> String = {
        coordinates, serverName in
        
        let result = 17 - coordinates[2]
        return "\(result)"
    }
    
    
    private let getInvY: ([Int], String) -> String = {
        coordinates, serverName in
        
        let z = Double(coordinates[2])
        let result = Int(pow(2.0, z)) - coordinates[1] - 1
        return String(result)
    }
    
    
    private let getSasZ: ([Int], String) -> String = {
        coordinates, serverName in
        
        let result = 1 + coordinates[2]
        return "\(result)"
    }
    
    
    private let getFolderX: ([Int], String) -> String = {
        coordinates, serverName in
        
        let result = Int(coordinates[0] / 1024)
        return "\(result)"
    }
    
    
    private let getFolderY: ([Int], String) -> String = {
        coordinates, serverName in
        
        let result = Int(coordinates[1] / 1024)
        return "\(result)"
    }
    
    
    private let getYandexX: ([Int], String) -> String = {
        coordinates, serverName in
        
        return "\(coordinates[0])"
    }
    
    
    private let getYandexY: ([Int], String) -> String = {
        coordinates, serverName in
        
        return "\(coordinates[1])"
    }
    
    private let getYandexTimestamp: ([Int], String) -> String = {
        coordinates, serverName in
        
        let timeInterval = Int( NSDate().timeIntervalSince1970 )
        return "\(timeInterval)"
    }
    
    
    
    
    
    
    // Two arrays for quick and short iterating of all this functions
    
    private let urlPlaceholders = ["{x}", "{y}", "{z}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}", "{timeStamp}"]
    
    private lazy var urlTransformers = [getX, getY, getZ, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY, getYandexTimestamp]
    
    
    
}
