//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor
import Foundation


class ImageProcessor {
    
    
    
    
    
    func getTestImage(_ req: Request) throws -> Response {
        // add controller code here
        // to determine which image is returned
        //        let filePath = "/Public/0.png"
        //        let fileUrl = URL(fileURLWithPath: filePath)
        
        let directory = DirectoryConfig.detect()
        let fileUrl = URL(fileURLWithPath: directory.workDir)
            .appendingPathComponent("Public", isDirectory: true)
            .appendingPathComponent("0.png")
        
        do {
            let data = try Data(contentsOf: fileUrl)
            // makeResponse(body: LosslessHTTPBodyRepresentable, as: MediaType)
            let response: Response = req.makeResponse(data, as: MediaType.png)
            return response
        } catch {
            let response: Response = req.makeResponse("image not available")
            return response
        }
    }
}
