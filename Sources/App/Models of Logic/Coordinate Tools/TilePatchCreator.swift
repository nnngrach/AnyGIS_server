//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor


class TilePatchCreator {
    
    
    func calculateTileURL(_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapData) -> String {
        
        var result = mapObject.backgroundUrl
        let serverName = mapObject.backgroundServerName
        let coordinates = [x, y, z]
        
        for i in 0 ..< urlPlaceholders.count {
            let replacedText = urlPlaceholders[i]
            let transformerClosure = urlTransformers[i]
            
            if result.contains(replacedText) {
                let newText = transformerClosure(coordinates, serverName, self)
                result = result.replacingOccurrences(of: replacedText, with: newText)
                
            } else {
                continue
            }
        }
        
        return result
    }
    
    
    
    func calculateFourTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapData) -> [String] {
        let topLeftTileUrl = calculateTileURL(x, y, z, mapObject)
        let topRightTileUrl = calculateTileURL(x+1, y, z, mapObject)
        let bottomRightTileUrl = calculateTileURL(x+1, y+1, z, mapObject)
        let bottomLeftTileUrl = calculateTileURL(x, y+1, z, mapObject)
        
        return [topLeftTileUrl, topRightTileUrl, bottomRightTileUrl, bottomLeftTileUrl]
    }
    
    
    
    
    
    // Heroku server doesn't works with Swift's standart arc4random functions.
    // So this is my silple realisation of it.
    
    func randomForHeroku(_ max: Int) -> Int {
        let unixTime = Date().timeIntervalSince1970
        let lastDigit = Int(String(String(unixTime).last!))!
        let randomInRange = lastDigit % max
        return randomInRange
    }
    
    
    
    
    
    
    
    // All URL replacing functions
    // (I can't call any functions of this class from closures)
    // ("self" does't works. So i using dependency injection)
    
    let getX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    let getY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    
    
    let getZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[2])"
    }
    
    
    let getS: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        if serverName == "wikimapia" {
            let result = ((coordinates[0]%4) + (coordinates[1]%4)*4)
            return "\(result)"
        } else {
            let serverLetters = Array(serverName)
            let randomNumber = transformer.randomForHeroku(serverLetters.count)
            return String(serverLetters[randomNumber])
        }
    }
    
    
    let getGoogleZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = 17 - coordinates[2]
        return "\(result)"
    }
    
    
    let getInvY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let z = Double(coordinates[2])
        let result = Int(pow(2.0, z)) - coordinates[1] - 1
        return String(result)
    }
    
    
    let getSasZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = 1 + coordinates[2]
        return "\(result)"
    }
    
    
    let getFolderX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[0] / 1024)
        return "\(result)"
    }
    
    
    let getFolderY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[1] / 1024)
        return "\(result)"
    }
    
    
    let getYandexX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    let getYandexY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    
    let getYandexTimestamp: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let timeInterval = Int( NSDate().timeIntervalSince1970 )
        return "\(timeInterval)"
    }
    
    
    
    
    
    
    
    
    
    // Two arrays for quick and short iterating of all this functions
    
    let urlPlaceholders = ["{x}", "{y}", "{z}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}", "{timeStamp}"]
    
    lazy var urlTransformers = [getX, getY, getZ, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY, getYandexTimestamp]
    

    
}
