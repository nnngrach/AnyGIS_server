//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 05/09/2019.
//

import Vapor

class ImageProcessor {
    
    // My DigitalOcean droplet with Image processing service
    let host = "http://localhost:5000/"
    //let host = "http://68.183.65.138:3000/"
    
    
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
    
    
    
    func opacity(value: Double, url: String, req: Request) throws -> Future<Response> {
        
        let apiUrl = host + "opacity"
        
        let message = ImageProcessorOpacityMessage(url: url,
                                                   value: String(value))
        
        let postResponse = try req.client().post(apiUrl) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    
    func text(message: String, isWhite: Bool, req: Request) throws -> Future<Response> {
        
        let apiUrl = host + "text"
        
        print(isWhite)
        let message = ImageProcessorTextMessage(message: message, isWhite: String(isWhite))
        
        let postResponse = try req.client().post(apiUrl) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
 
}
