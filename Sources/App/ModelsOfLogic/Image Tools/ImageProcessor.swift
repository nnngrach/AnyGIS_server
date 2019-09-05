//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 05/09/2019.
//

import Vapor

class ImageProcessor {
    
    func move(tilesUrl: [String], xOffset: Int, yOffset: Int, req: Request) throws -> Future<Response> {
        
        let host = "http://localhost:5000/move"
        
        let message = ImageProcessorMoveMessage(urlTL: tilesUrl[0],
                                                urlTR: tilesUrl[1],
                                                urlBR: tilesUrl[2],
                                                urlBL: tilesUrl[3],
                                                xOffset: String(xOffset),
                                                yOffset: String(yOffset))
        
//        let message = CloudinaryPostMessage(file: sourceUrl,
//                                            public_id: name,
//                                            upload_preset: "guestPreset")
        
        let postResponse = try req.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
}
