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
    
    
    public func calculateFourNextZoomTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ url:String, _ serverName:String) -> [String] {
        let topLeftTileUrl = calculateTileURL(x*2, y*2, z+1, url, serverName)
        let topRightTileUrl = calculateTileURL(x*2+1, y*2, z+1, url, serverName)
        let bottomRightTileUrl = calculateTileURL(x*2+1, y*2+1, z+1, url, serverName)
        let bottomLeftTileUrl = calculateTileURL(x*2, y*2+1, z+1, url, serverName)
        
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
    
    
    private let getZMinus6: ([Int], String) -> String = {
        coordinates, serverName in
        
        let result = coordinates[2] - 6
        return "\(result)"
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
    
    
    
    private let getKosmosnimkiX: ([Int], String) -> String = {
        coordinates, serverName in
        
        let zPow = Int(pow(2.0, Double(coordinates[2])))
        let newX = coordinates[0] - zPow / 2
        
        return "\(newX)"
    }
    
    
    private let getKosmosnimkiY: ([Int], String) -> String = {
        coordinates, serverName in
        
        let zPow = Int(pow(2.0, Double(coordinates[2])))
        let newY = (zPow - coordinates[1] - 1) - zPow / 2
        
        return "\(newY)"
    }
    
    
    private let getMetersL: ([Int], String) -> String = {
        coordinates, serverName in
        
        let xPlanetDistance = 40075016.6855784878
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = xPlanetDistance / tileCounsPerZoom * Double(coordinates[0]) - xPlanetDistance/2.0
        
        return "\(distance)"
    }
    
    
    private let getMetersR: ([Int], String) -> String = {
        coordinates, serverName in
        
        let xPlanetDistance = 40075016.6855784878
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = xPlanetDistance / tileCounsPerZoom * Double(coordinates[0] + 1) - xPlanetDistance/2.0
        
        return "\(distance)"
    }
    
    
    private let getMetersT: ([Int], String) -> String = {
        coordinates, serverName in
        
        let yPlanetDistance = 40075016.6855784804
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = yPlanetDistance / tileCounsPerZoom * Double(coordinates[1]) - yPlanetDistance/2.0
        
        return "\(-distance)"
    }
    
    
    private let getMetersB: ([Int], String) -> String = {
        coordinates, serverName in
        
        let yPlanetDistance = 40075016.6855784804
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = yPlanetDistance / tileCounsPerZoom * Double(coordinates[1] + 1) - yPlanetDistance/2.0
        
        return "\(-distance)"
    }
    
    
    
    private let getQuad: ([Int], String) -> String = {
        coordinates, serverName in
        
        let geoTransformer = BingTileNumberTransformer()
        
        let quad = geoTransformer.tileXYToQuadKey(tileX: coordinates[0], tileY: coordinates[1], levelOfDetail: coordinates[2])
        
        return quad
    }
    
    
    
    // Two arrays for quick and short iterating of all this functions
    
    private let urlPlaceholders = ["{x}", "{y}", "{z}", "{z-6}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}", "{timeStamp}", "{kosmosnimkiX}", "{kosmosnimkiY}", "{left}", "{right}", "{top}", "{bottom}", "{q}"]
    
    private lazy var urlTransformers = [getX, getY, getZ, getZMinus6, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY, getYandexTimestamp, getKosmosnimkiX, getKosmosnimkiY, getMetersL, getMetersR, getMetersT, getMetersB, getQuad]
    
    
    
}
