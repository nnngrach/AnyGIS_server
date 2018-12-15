//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor



class ImageProcessor {
    
    
    struct CloudinaryPostMessage: Content {
        var file: String
        var public_id: String
        var upload_preset: String
    }
    
    struct CloudinaryImgUrl: Content {
        var url: String
    }
    
    
    
    func makeName(sourceUrl: String) -> String {
        let range = sourceUrl.index(sourceUrl.startIndex, offsetBy: 30)..<sourceUrl.endIndex
        let removingChars = "~+?.,!@:;<>{}[/\\]#$%^&*=|`\'\""
        
        var filenameString = String(sourceUrl[range])
        
        for char in removingChars {
            filenameString = filenameString.replacingOccurrences(of: String(char), with: "")
        }
        
        return filenameString
    }
    
    
    
    func upload(sourceUrl: String, request: Request) throws -> Future<Response> {
        
        let host = "https://api.cloudinary.com/v1_1/nnngrach/image/upload"
        let name = makeName(sourceUrl: sourceUrl)
        
        let message = CloudinaryPostMessage(file: sourceUrl,
                                            public_id: name,
                                            upload_preset: "guestPreset")
        
        let postResponse = try request.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    
    
    func show (responce: Future<Response>, request: Request) throws -> Future<Response> {
        
        let redirectingRespocence = responce.flatMap(to: Response.self) { res in
            
            let futContent = try res.content.decode(CloudinaryImgUrl.self)
            
            let newResponce = futContent.map(to: Response.self) { content in
                let loadedImageUrl = content.url
                return request.redirect(to: loadedImageUrl)
            }
            
            return newResponce
        }
        
        return redirectingRespocence
    }
    
    
    
   
    
    
    
    
    
    
    
    
    
    
 //===================================
    func loadImage(filePatch: URL) -> ProcessingResult {
        do {
            let data = try Data(contentsOf: filePatch)
            let extention = filePatch.pathExtension
            return ProcessingResult.image(imageData: data, extention: extention)
            
        } catch {
            return ProcessingResult.error(description: "Image not available")
        }
    }
    
   
    
    
    
 /*
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
 
 */
    
}
