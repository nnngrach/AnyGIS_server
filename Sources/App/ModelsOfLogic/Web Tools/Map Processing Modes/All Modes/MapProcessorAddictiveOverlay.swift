//
//  MapProcessorAddictiveOverlay.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 06/10/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//


import Vapor

class MapProcessorAddictiveOverlay: AbstractMapProcessorOverlay {
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        guard baseObject != nil && overlayObject != nil && cloudinarySessionID != nil else {return try output.serverErrorResponce("MapProcessor unwarping error", req)}
        
        
        let template = MapsList(name: "", mode: "redirect", backgroundUrl: "", backgroundServerName: "", referer: "", zoomMin: 0, zoomMax: 19, dpiSD: "", dpiHD: "", parameters: 0, description: "")
        
        
        template.backgroundUrl = SERVER_HOST + baseObject!.name + "\\" + String(tileNumbers.x) + "\\" + String(tileNumbers.y) + "\\" + String(tileNumbers.z)
        
        let baseUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, template)
        
        
        template.backgroundUrl = SERVER_HOST + overlayObject!.name + "\\" + String(tileNumbers.x) + "\\" + String(tileNumbers.y) + "\\" + String(tileNumbers.z)
        
        let overlayUrl = self.urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, template)
        
        
        // Not need to process Url at this step.
        // Just send to external ImageProcessor Url
        // to AnyGIS base and overlay maps
        
        return try imageProcessor.addictiveOverlay(backgroundUrl: baseUrl, overlayUrl: overlayUrl, req: req)
    }
    
}
