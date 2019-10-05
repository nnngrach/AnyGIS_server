//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor


class URLPatchCreator {
    
    
    
    public func calculateTileURL(_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapsList) -> String {
        
        var result = mapObject.backgroundUrl
        let coordinates = [x, y, z]
        
        for i in 0 ..< urlPlaceholders.count {
            let replacedText = urlPlaceholders[i]
            let transformerClosure = urlTransformers[i]
            
            if result.contains(replacedText) {
                let newText = transformerClosure(coordinates, mapObject)
                result = result.replacingOccurrences(of: replacedText, with: newText)
                
            } else {
                continue
            }
        }
        
        return result
    }
    
    
    
    public func calculateFourTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapsList) -> [String] {
        
        let maxTileNumber = Int(pow(2.0, Double(z))) - 1
        let rightTileNumber = (x == maxTileNumber) ? 0 : x+1
        let bottomTileNumber = (y == maxTileNumber) ? 0 : y+1
        
        let topLeftTileUrl = calculateTileURL(x, y, z, mapObject)
        let topRightTileUrl = calculateTileURL(rightTileNumber, y, z, mapObject)
        let bottomRightTileUrl = calculateTileURL(rightTileNumber, bottomTileNumber, z, mapObject)
        let bottomLeftTileUrl = calculateTileURL(x, bottomTileNumber, z, mapObject)
        
        return [topLeftTileUrl, topRightTileUrl, bottomRightTileUrl, bottomLeftTileUrl]
    }
    
    
    public func calculateFourNextZoomTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapsList) -> [String] {
        
        // let maxTileNumber = Int(pow(2.0, Double(z+1))) - 1
        // let rightTileNumber = (x == maxTileNumber) ? 0 : x*2+1
        // let bottomTileNumber = (y == maxTileNumber) ? 0 : y*2+1
        
        let topLeftTileUrl = calculateTileURL(x*2, y*2, z+1, mapObject)
        let topRightTileUrl = calculateTileURL(x*2+1, y*2, z+1, mapObject)
        let bottomRightTileUrl = calculateTileURL(x*2+1, y*2+1, z+1, mapObject)
        let bottomLeftTileUrl = calculateTileURL(x*2, y*2+1, z+1, mapObject)
        
        return [topLeftTileUrl, topRightTileUrl, bottomRightTileUrl, bottomLeftTileUrl]
    }
    
    
    
    
    
    // All URL replacing functions
    // (I can't call any functions of this class from closures)
    // ("self" does't works. So i using dependency injection)
    
    private let getX: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        return "\(coordinates[0])"
    }
    
    
    private let getY: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        return "\(coordinates[1])"
    }
    
    
    private let getZ: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        return "\(coordinates[2])"
    }
    
    
    private let getZMinus6: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = coordinates[2] - 6
        return "\(result)"
    }
    
    private let getZMinus2: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = coordinates[2] - 2
        return "\(result)"
    }
    
    
    private let getS: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let serverName = mapObject.backgroundServerName
        
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
    
    
    private let getGoogleZ: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = 17 - coordinates[2]
        return "\(result)"
    }
    
    
    private let getInvY: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let z = Double(coordinates[2])
        let result = Int(pow(2.0, z)) - coordinates[1] - 1
        return String(result)
    }
    
    
    private let getSasZ: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = 1 + coordinates[2]
        return "\(result)"
    }
    
    
    private let getFolderX: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = Int(coordinates[0] / 1024)
        return "\(result)"
    }
    
    
    private let getFolderY: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let result = Int(coordinates[1] / 1024)
        return "\(result)"
    }
    
    
    private let getYandexX: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        return "\(coordinates[0])"
    }
    
    
    private let getYandexY: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        return "\(coordinates[1])"
    }
    
    private let getYandexTimestamp: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let timeInterval = Int( NSDate().timeIntervalSince1970 )
        return "\(timeInterval)"
    }
    
    
    
    private let getKosmosnimkiX: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let zPow = Int(pow(2.0, Double(coordinates[2])))
        let newX = coordinates[0] - zPow / 2
        
        return "\(newX)"
    }
    
    
    private let getKosmosnimkiY: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let zPow = Int(pow(2.0, Double(coordinates[2])))
        let newY = (zPow - coordinates[1] - 1) - zPow / 2
        
        return "\(newY)"
    }
    
    
    private let getMetersL: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let xPlanetDistance = 40075016.6855784878
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = xPlanetDistance / tileCounsPerZoom * Double(coordinates[0]) - xPlanetDistance/2.0
        
        return "\(distance)"
    }
    
    
    private let getMetersR: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let xPlanetDistance = 40075016.6855784878
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = xPlanetDistance / tileCounsPerZoom * Double(coordinates[0] + 1) - xPlanetDistance/2.0
        
        return "\(distance)"
    }
    
    
    private let getMetersT: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let yPlanetDistance = 40075016.6855784804
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = yPlanetDistance / tileCounsPerZoom * Double(coordinates[1]) - yPlanetDistance/2.0
        
        return "\(-distance)"
    }
    
    
    private let getMetersB: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let yPlanetDistance = 40075016.6855784804
        let tileCounsPerZoom = pow(2.0, Double(coordinates[2]))
        let distance = yPlanetDistance / tileCounsPerZoom * Double(coordinates[1] + 1) - yPlanetDistance/2.0
        
        return "\(-distance)"
    }
    
    
    
    private let getQuad: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let geoTransformer = BingTileNumberTransformer()
        
        let quad = geoTransformer.tileXYToQuadKey(tileX: coordinates[0], tileY: coordinates[1], levelOfDetail: coordinates[2])
        
        return quad
    }
    
    
    private let getResolution: ([Int], MapsList) -> String = {
        coordinates, mapObject in
        
        let defauldDpi = mapObject.dpiSD
        return "\(defauldDpi)"
    }
    
    
    // Two arrays for quick and short iterating of all this functions
    
    private let urlPlaceholders = ["{x}", "{y}", "{z}", "{z-2}", "{z-6}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}", "{timeStamp}", "{kosmosnimkiX}", "{kosmosnimkiY}", "{left}", "{right}", "{top}", "{bottom}", "{q}", "{ts}"]
    
    private lazy var urlTransformers = [getX, getY, getZ, getZMinus2, getZMinus6, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY, getYandexTimestamp, getKosmosnimkiX, getKosmosnimkiY, getMetersL, getMetersR, getMetersT, getMetersB, getQuad, getResolution]
    
    
    
}
