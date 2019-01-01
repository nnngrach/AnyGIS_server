//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor


class TilePatchCreator {
    
    
    public func calculateTileURL(_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapsList) -> String {
        
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
    
    
    
    public func calculateFourTilesUrls (_ x: Int, _ y: Int, _ z: Int, _ mapObject: MapsList) -> [String] {
        let topLeftTileUrl = calculateTileURL(x, y, z, mapObject)
        let topRightTileUrl = calculateTileURL(x+1, y, z, mapObject)
        let bottomRightTileUrl = calculateTileURL(x+1, y+1, z, mapObject)
        let bottomLeftTileUrl = calculateTileURL(x, y+1, z, mapObject)
        
        return [topLeftTileUrl, topRightTileUrl, bottomRightTileUrl, bottomLeftTileUrl]
    }
    
    
    
    
    
    // Heroku server doesn't works with Swift's standart arc4random functions.
    // So this is my silple realisation of it.
    
    private func randomForHeroku(_ max: Int) -> Int {
        let unixTime = Date().timeIntervalSince1970
        let lastDigit = Int(String(String(unixTime).last!))!
        let randomInRange = lastDigit % max
        return randomInRange
    }
    
    
    
    
    
    
    
    // All URL replacing functions
    // (I can't call any functions of this class from closures)
    // ("self" does't works. So i using dependency injection)
    
    private let getX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    private let getY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    
    
    private let getZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[2])"
    }
    
    
    private let getS: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        switch serverName {
        case "wikimapia":
            let result = ((coordinates[0]%4) + (coordinates[1]%4)*4)
            return "\(result)"
            
        case "sasPlanetOnly":
            return "http://91.237.82.95:8088/"
            
        case "sasAndMelda":
            let mirrors = ["http://91.237.82.95:8088",
                            "https://maps.melda.ru"]
            let randomNumber = transformer.randomForHeroku(mirrors.count)
            return mirrors[randomNumber]
            
        case "sasGenshtab":
            let mirrors = ["http://91.237.82.95:8088",
                           "https://maps.melda.ru",
                           "http://t.caucasia.ru:80/"]
            let randomNumber = transformer.randomForHeroku(mirrors.count)
            return mirrors[randomNumber]
            
        default:
            let serverLetters = Array(serverName)
            let randomNumber = transformer.randomForHeroku(serverLetters.count)
            return String(serverLetters[randomNumber])
        }
    }
    
    
    private let getGoogleZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = 17 - coordinates[2]
        return "\(result)"
    }
    
    
    private let getInvY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let z = Double(coordinates[2])
        let result = Int(pow(2.0, z)) - coordinates[1] - 1
        return String(result)
    }
    
    
    private let getSasZ: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = 1 + coordinates[2]
        return "\(result)"
    }
    
    
    private let getFolderX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[0] / 1024)
        return "\(result)"
    }
    
    
    private let getFolderY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[1] / 1024)
        return "\(result)"
    }
    
    
    private let getYandexX: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    private let getYandexY: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    
    private let getYandexTimestamp: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let timeInterval = Int( NSDate().timeIntervalSince1970 )
        return "\(timeInterval)"
    }
    
    
    private let getMapboxMapniklayer: ([Int], String, TilePatchCreator) -> String = {
        coordinates, serverName, transformer in
        
        let firstParts = [
            "https://api.mapbox.com/styles/v1/nnngrach/cjot3z99v0i5e2rqg319j4dxg/tiles/256/",
            "https://api.mapbox.com/styles/v1/nnngrach2/cjot5o6fq38dq2snohos5m1ws/tiles/256/",
            "https://api.mapbox.com/styles/v1/nnngrach3/cjot5ygtc3avq2ro4q9mcozbk/tiles/256/",
            "https://api.mapbox.com/styles/v1/nnngrach4/cjot6btfv89k52rp6oy8zkgju/tiles/256/"]
        
        let secondParts = [
            "@2x?access_token=pk.eyJ1Ijoibm5uZ3JhY2giLCJhIjoiY2pvc3lwcDhwMHQwMzNxbGh5cmIzMzR5ayJ9.uW0dUw6sZCBcrL0cg0JgLA",
            "@2x?access_token=pk.eyJ1Ijoibm5uZ3JhY2gyIiwiYSI6ImNqb3Q1bnVoazB2NHgzc25yYXNlbjZ6NXEifQ.Icvq22SoRbXWafVls1vQzw",
            "@2x?access_token=pk.eyJ1Ijoibm5uZ3JhY2gzIiwiYSI6ImNqb3Q1d3J4YzB2NXQzcWtmZjZ5ZjdzNmEifQ.JfDmgQvzdsfSKHqaH-KSow",
            "@2x?access_token=pk.eyJ1Ijoibm5uZ3JhY2g0IiwiYSI6ImNqb3Q2YTA2eDB2N2Eza285bndzbWxtbzEifQ.5oZcsK5zbp5mXCfCT-f_XQ"]
        
        let randomNumber = transformer.randomForHeroku(firstParts.count)
        
        return firstParts[randomNumber] + "{z}/{x}/{y}" + secondParts[randomNumber]
    }
    
    
    
    
    
    
    // Two arrays for quick and short iterating of all this functions
    
    private let urlPlaceholders = ["{mapboxMapnik}", "{x}", "{y}", "{z}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}", "{timeStamp}"]
    
    private lazy var urlTransformers = [getMapboxMapniklayer, getX, getY, getZ, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY, getYandexTimestamp]
    

    
}
