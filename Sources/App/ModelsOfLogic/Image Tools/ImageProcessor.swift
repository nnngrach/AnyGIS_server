//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 05/09/2019.
//

import Vapor

class ImageProcessor {
    
    let host = "http://localhost:5000/"

    
    func move(tilesUrl: [String], xOffset: Int, yOffset: Int, req: Request) throws -> Future<Response> {
        
        let apiUrl = host + "move"
        
        let message = ImageProcessorMoveMessage(urlTL: tilesUrl[0],
                                                urlTR: tilesUrl[1],
                                                urlBR: tilesUrl[2],
                                                urlBL: tilesUrl[3],
                                                xOffset: String(xOffset),
                                                yOffset: String(yOffset))
        
        let postResponse = try req.client().post(apiUrl) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    
    func overlay(backgroundUrl: String, overlayUrl: String, req: Request) throws -> Future<Response> {
        
        let apiUrl = host + "overlay"
        
        let message = ImageProcessorOverlayMessage(backgroundUrl: backgroundUrl,
                                                   overlayUrl: overlayUrl)
        
        let postResponse = try req.client().post(apiUrl) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    
    func moveAndOverlay(tilesUrl: [String], xOffset: Int, yOffset: Int, overlayUrl: String, req: Request) throws -> Future<Response> {
        
        let apiUrl = host + "move_and_overlay"
        
        let message = ImageProcessorMoveAndOverlayMessage(urlTL: tilesUrl[0],
                                                urlTR: tilesUrl[1],
                                                urlBR: tilesUrl[2],
                                                urlBL: tilesUrl[3],
                                                xOffset: String(xOffset),
                                                yOffset: String(yOffset),
                                                overlayUrl: overlayUrl)
        
        let postResponse = try req.client().post(apiUrl) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
}
