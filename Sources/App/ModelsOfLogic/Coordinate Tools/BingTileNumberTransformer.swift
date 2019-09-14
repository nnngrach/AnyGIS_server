//
//  BingTileNumberTransformer.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 14/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Foundation

class BingTileNumberTransformer {
    
    // Source from:
    // https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
    
    private let earthRadius: Double = 6378137
    private let minLatitude: Double = -85.05112878
    private let maxLatitude: Double = 85.05112878
    private let minLongitude: Double = -180
    private let maxLongitude: Double = 180
    
    
    private func clip(n: Double, minValue: Double, maxValue: Double) -> Double {
        return min( (max(n, minValue)), maxValue)
    }
    
    
    public func mapSize(levelOfDetail: Int) -> Double {
        return Double(256 << levelOfDetail)
    }
    
    
    public func groundResolution(latitude: Double, levelOfDetail: Int) -> Double {
        
        let clippedLantitude = clip(n: latitude, minValue: minLatitude, maxValue: maxLatitude)
        
        return cos(clippedLantitude * M_PI / 180) * 2 * M_PI * earthRadius / mapSize(levelOfDetail: levelOfDetail)
    }
    
    
    public func mapScale(latitude: Double, levelOfDetail: Int, screenDpi: Int) -> Double {
        
        let ratio = 0.0254
        
        return groundResolution(latitude: latitude, levelOfDetail: levelOfDetail) * Double(screenDpi) / ratio
    }
    
    
    
    public func latLongToPixelXY(latitude: Double, longitude: Double, levelOfDetail: Int) -> (x: Int, y: Int) {
        
        let clippedLatitude = clip(n: latitude, minValue: minLatitude, maxValue: maxLatitude)
        let clippedLongitude = clip(n: longitude, minValue: minLongitude, maxValue: maxLongitude)
        
        let x: Double = (clippedLongitude + 180) / 360
        let sinLatitude: Double = sin(clippedLongitude * M_PI / 180)
        let y: Double = 0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * M_PI)
        
        let currentMapSize: Double = Double(mapSize(levelOfDetail: levelOfDetail))
        let pixelX: Int = Int( clip(n: (x * currentMapSize + 0.5), minValue: 0, maxValue: (currentMapSize - 1)) )
        let pixelY: Int = Int( clip(n: (y * currentMapSize + 0.5), minValue: 0, maxValue: (currentMapSize - 1)) )
        
        return (x: pixelX, y: pixelY)
    }
    
    
    
    public func pixelXYToLatLong(pixelX: Int, pixelY: Int, levelOfDetail: Int) -> (latitude: Double, longitude: Double) {
        
        let currentMapSize: Double = mapSize(levelOfDetail: levelOfDetail)
        let x: Double = (clip(n: Double(pixelX), minValue: 0, maxValue: (currentMapSize - 1)) - currentMapSize) - 0.5
        let y: Double = 0.5 - (clip(n: Double(pixelY), minValue: 0, maxValue: (currentMapSize - 1)) / currentMapSize)
        
        let latitude: Double = 90 - 360 * atan(exp(-y * 2 * M_PI)) / M_PI
        let longitude: Double = 360 * x
        
        return (latitude: latitude, longitude: longitude)
    }
    
    
    
    public func pixelXYToTileXY(pixelX: Int, pixelY: Int) -> (tileX: Int, tileY: Int) {
        
        return (tileX: pixelX / 256, tileY: pixelY / 256)
    }
    
    
    public func tileXYToPixelXY(tileX: Int, tileY: Int) -> (pixelX: Int, pixelY: Int) {
        
        return (pixelX: tileX * 256, pixelY: tileY * 256)
    }
    
    
    
    public func tileXYToQuadKey(tileX: Int, tileY: Int, levelOfDetail: Int) -> String {
        
        var quadKey: String = ""
        
        for i in (1 ... levelOfDetail).reversed() {
            
            var digit: Int = 0
            let mask: Int = 1 << (i - 1)
            
            if tileX & mask != 0 {
                digit += 1
            }
            if tileY & mask != 0 {
                digit += 2
            }
            
            quadKey.append( String(digit))
        }
        
        return quadKey
    }
    
    
    
    public func quadKeyToTileXY(quadKey: String) throws -> (tileX: Int, tileY: Int, levelOfDetail: Int) {
        
        var tileX = 0
        var tileY = 0
        let levelOfDetail = quadKey.count
        
        for i in (1 ... levelOfDetail).reversed() {
            
            let mask: Int = 1 << (i - 1)
            
            let character = getCharacterOf(string: quadKey, atIndex: (levelOfDetail - i))
            
            switch character {
            case "0":
                break
                
            case "1":
                tileX |= mask
                
            case "2":
                tileY |= mask
                
            case "3":
                tileX |= mask
                tileY |= mask
                
            default:
                // "Invalid QuadKey digit sequence."
                throw GlobalErrors.parsingFail
            }
        }
        
        return (tileX: tileX, tileY: tileY, levelOfDetail: levelOfDetail)
    }
    
    
    
    
    private func getCharacterOf(string: String, atIndex index: Int) -> Character {
        
        let characterIndex = string.index(string.startIndex, offsetBy: index)
        return string[characterIndex]
    }
    
    
}
