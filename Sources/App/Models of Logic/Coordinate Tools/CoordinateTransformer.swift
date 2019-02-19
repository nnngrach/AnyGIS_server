//
//  CoordinateTransformer.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation

class CoordinateTransformer {
    
    // MARK: Web Mercator transformations
    
    public func calculateTileNumbers(_ xText: String, _ yText: String, _ zoom: Int) throws -> (x: Int, y: Int) {
        
        // If user find by lat/log (as double)
        if (xText.contains(".") || yText.contains(".")) {
            
            guard let latitude = Double(xText) else { throw TransformerError.inputValueIsNotDOUBLE}
            guard let longitude = Double(yText) else { throw TransformerError.inputValueIsNotDOUBLE}
            
            return coordinatesToTileNumbers(latitude, longitude, withZoom: zoom)
            
            
            // If user find directly by tile numbers (as int)
        } else {
            guard let xTile = Int(xText) else { throw TransformerError.inputValueIsNotINT}
            guard let yTile = Int(yText) else { throw TransformerError.inputValueIsNotINT}
            return (xTile, yTile)
        }
    }
    

    
    
    
    private func coordinatesToTileNumbers(_ latitude: Double, _ longitude: Double, withZoom zoom: Int) -> (x: Int, y: Int) {
        let tileX = Int(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
        let tileY = Int(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
        
        return (tileX, tileY)
    }
    
    
    public func tileNumberToCoordinates(_ tileX : Int, _ tileY : Int, _ mapZoom: Int) -> (lat_deg : Double, lon_deg : Double) {
        let n : Double = pow(2.0, Double(mapZoom))
        let lon = (Double(tileX) / n) * 360.0 - 180.0
        let lat = atan( sinh (.pi - (Double(tileY) / n) * 2 * Double.pi)) * (180.0 / .pi)
        
        return (lat, lon)
    }
    
    
    
    
    
    // MARK: WGS-84 proection transformations
    
    public func getWGS84Position(_ latitude: Double, _ longitude: Double, withZoom zoom: Int) -> (x:Int, y:Int, offsetX:Int, offsetY:Int) {
        
        // Earth vertical and horisontal radiuses
        let radiusA = 6378137.0
        let radiusB = 6356752.0
        
        // I really don't know what the names of these variables mean =(
        
        let latitudeInRadians = latitude * Double.pi / 180
        
        let j2 = sqrt( pow(radiusA, 2.0) - pow(radiusB, 2.0)) / radiusA
        
        let m2 = log((1 + sin(latitudeInRadians)) / (1 - sin(latitudeInRadians))) / 2 - j2 * log((1 + j2 * sin(latitudeInRadians)) / (1 - j2 * sin(latitudeInRadians))) / 2
        
        // xTilesCountForThisZoom equal yTilesCountForThisZoom
        let xTilesCountForThisZoom = Double(1 << zoom)
        
        //Tile numbers in WGS-84 proection
        let tileX = floor((longitude + 180) / 360 * xTilesCountForThisZoom)
        let tileY = floor(xTilesCountForThisZoom / 2 - m2 * xTilesCountForThisZoom / 2 / Double.pi)
        
        //Offset in pixels of the coordinate of the
        //left-top corner of the OSM tile
        //from the left-top corner of the WGS-84 tile
        let offsetX = floor(((longitude + 180) / 360 * xTilesCountForThisZoom - tileX) * 256)
        let offsetY = floor(((xTilesCountForThisZoom / 2 - m2 * xTilesCountForThisZoom / 2 / Double.pi) - tileY) * 256)
        
        return (Int(tileX), Int(tileY), Int(offsetX), Int(offsetY))
    }
    
    
}
