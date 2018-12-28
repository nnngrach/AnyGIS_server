//
//  UrlTransformer.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/12/2018.
//

import Foundation

class UrlTransformer {
    
    // Two arrays for quick and short iterating of all this functions
    
    let urlPlaceholders = ["{x}", "{y}", "{z}", "{s}", "{googleZ}", "{invY}", "{sasZ}", "{folderX}", "{folderY}", "{yandexX}", "{yandexY}"]
    
    lazy var urlTransformers = [getX, getY, getZ, getS, getGoogleZ, getInvY, getSasZ, getFolderX, getFolderY, getYandexX, getYandexY]
    
    
    
    
    // All URL replacing functions
    // (I can't call any functions of this class from closures)
    // ("self" does't works. So i using dependency injection)
    
    let getX: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    let getY: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    
    
    let getZ: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[2])"
    }
    
    
    let getS: ([Int], String, UrlTransformer) -> String = {
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
    
    
    let getGoogleZ: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        let result = 17 - coordinates[2]
        return "\(result)"
    }
    
    
    let getInvY: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        let z = Double(coordinates[2])
        let result = Int(pow(2.0, z)) - coordinates[1] - 1
        return String(result)
    }
    
    
    let getSasZ: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        let result = 1 + coordinates[2]
        return "\(result)"
    }
    
    
    let getFolderX: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[0] / 1024)
        return "\(result)"
    }
    
    
    let getFolderY: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        let result = Int(coordinates[1] / 1024)
        return "\(result)"
    }
    
    
    let getYandexX: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[0])"
    }
    
    
    let getYandexY: ([Int], String, UrlTransformer) -> String = {
        coordinates, serverName, transformer in
        
        return "\(coordinates[1])"
    }
    

    

    
    // Heroku server doesn't works with Swift's standart arc4random functions.
    // So this is my silple realisation of it.
    
    func randomForHeroku(_ max: Int) -> Int {
        let unixTime = Date().timeIntervalSince1970
        let lastDigit = Int(String(String(unixTime).last!))!
        let randomInRange = lastDigit % max
        return randomInRange
    }
    

}
