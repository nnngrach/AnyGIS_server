//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor

class ImageProcessor {
    
    
    //MARK: Generate filename
    
    private func makeName(_ sourceUrl: String) -> String {
        
        var range: Range<String.Index>
        let yandexNarodMapUrlLenght = 580
        let serverPartOffset = 13
        
        if sourceUrl.count >= yandexNarodMapUrlLenght {
            range = sourceUrl.index(sourceUrl.startIndex, offsetBy: yandexNarodMapUrlLenght)..<sourceUrl.endIndex
            
        } else if sourceUrl.count >= serverPartOffset {
            range = sourceUrl.index(sourceUrl.startIndex, offsetBy: serverPartOffset)..<sourceUrl.endIndex
            
        } else {
            range = sourceUrl.startIndex..<sourceUrl.endIndex
        }
        
        
        let removingChars = "~+?.,!@:;<>{}[/\\]#$%^&*=|`\'\""
        
        var filenameString = String(sourceUrl[range])
        
        for char in removingChars {
            filenameString = filenameString.replacingOccurrences(of: String(char), with: "")
        }
        
        //print(filenameString)
        return filenameString
    }
    
    
    
    //MARK: Uploading image to Cloudinary server
    
    private func upload(_ sourceUrl: String, _ request: Request) throws -> Future<Response> {
        
        let host = "https://api.cloudinary.com/v1_1/nnngrach/image/upload"
        let name = makeName(sourceUrl)
        
        let message = CloudinaryPostMessage(file: sourceUrl,
                                            public_id: name,
                                            upload_preset: "guestPreset")
        
        let postResponse = try request.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    public func uploadTwoTiles(_ sourceUrls: [String], _ request: Request) throws -> [Future<Response>] {
        
        let baseResponce = try upload(sourceUrls[0], request)
        let overlayResponce = try upload(sourceUrls[1], request)
        
        return [baseResponce, overlayResponce]
    }
    
    
    public func uploadFourTiles(_ sourceUrls: [String], _ request: Request) throws -> [Future<Response>] {

        let tlLoadingResponce = try upload(sourceUrls[0], request)
        let trLoadingResponce = try upload(sourceUrls[1], request)
        let brLoadingResponce = try upload(sourceUrls[2], request)
        let blLoadingResponce = try upload(sourceUrls[3], request)
        
        return [tlLoadingResponce, trLoadingResponce, brLoadingResponce, blLoadingResponce]
    }
    
    
    
    //MARK: Synchronizing Responces
    
    public func syncTwo(_ loadingResponces: [EventLoopFuture<Response>],
                                  _ req: Request,
                                  _ closure: @escaping (Request) -> (EventLoopFuture<Response>)) -> EventLoopFuture<Response> {
        
        return loadingResponces[0].flatMap(to: Response.self) { _ in
            return loadingResponces[1].flatMap(to: Response.self) { _ in
                //Body
                return closure(req)
            }
        }
    }
    
    
    
    
    public func syncFour(_ loadingResponces: [EventLoopFuture<Response>],
                                  _ req: Request,
                                  _ closure: @escaping (Request) -> (EventLoopFuture<Response>)) -> EventLoopFuture<Response> {
        
        return loadingResponces[0].flatMap(to: Response.self) { _ in
            return loadingResponces[1].flatMap(to: Response.self) { _ in
                return loadingResponces[2].flatMap(to: Response.self) { _ in
                    return loadingResponces[3].flatMap(to: Response.self) { _ in
                        
                        //Body
                        return closure(req)
                    }
                }
            }
        }
    }
    
    
    
    
    // ?
//    func show (_ responce: Future<Response>, _ request: Request) throws -> Future<Response> {
//        
//        let redirectingRespocence = responce.flatMap(to: Response.self) { res in
//            
//            let futContent = try res.content.decode(CloudinaryImgUrl.self)
//            
//            let newResponce = futContent.map(to: Response.self) { content in
//                let loadedImageUrl = content.url
//                return request.redirect(to: loadedImageUrl)
//            }
//            
//            return newResponce
//        }
//        
//        return redirectingRespocence
//    }
    
    
    
    
    //MARK: Generating URL to Cloudinary image
    
    public func getUrlOverlay(_ baseUrl: String, _ overlayUrl: String) -> String {
        let baseImgName = makeName(baseUrl)
        let overlayImgName = makeName(overlayUrl)

        return "https://res.cloudinary.com/nnngrach/image/upload/l_\(overlayImgName),w_256,o_100/\(baseImgName)"
    }
    
    
    public func getUrlWithOffset(_ urls: [String], _ offsetX: Int, _ offsetY: Int ) -> String {
        let topLeft = makeName(urls[0])
        let topRight = makeName(urls[1])
        let bottomRight = makeName(urls[2])
        let bottomLeft = makeName(urls[3])
        
        return "https://res.cloudinary.com/nnngrach/image/upload/l_\(topLeft),y_-256/l_\(topRight),x_256,y_-128/l_\(bottomRight),x_128,y_128/c_crop,g_north_west,w_256,h_256,x_\(offsetX),y_\(offsetY)/\(bottomLeft)"
    }
    
    
    
    public func getUrlWithOffsetAndOverlay(_ urls: [String], _ overlayUrls: [String], _ offsetX: Int, _ offsetY: Int ) -> String {
        let topLeft = makeName(urls[0])
        let topRight = makeName(urls[1])
        let bottomRight = makeName(urls[2])
        let bottomLeft = makeName(urls[3])
        
        let overTopLeft = makeName(overlayUrls[0])
        let overTopRight = makeName(overlayUrls[1])
        let overBottomRight = makeName(overlayUrls[2])
        let overBottomLeft = makeName(overlayUrls[3])
        
        return "https://res.cloudinary.com/nnngrach/image/upload/l_\(topLeft),y_-256/l_\(topRight),x_256,y_-128/l_\(bottomRight),x_128,y_128/l_\(overTopLeft),x_-128,y_-128/l_\(overTopRight),x_128,y_-128/l_\(overBottomLeft),x_-128,y_128/l_\(overBottomRight),x_128,y_128/c_crop,g_north_west,w_256,h_256,x_\(offsetX),y_\(offsetY)/\(bottomLeft)"
    }

   
    
  /*
    func getUrlWithOpacity(_ url: String, _ opacity: Int) -> String {
        //return "https://res.cloudinary.com/nnngrach/image/fetch/o_\(opacity)/\(url)"
        return "https://res.cloudinary.com/nnngrach/image/o_\(opacity)/\(url)"
    }
  */
    
    
    
 //===================================
//    func loadImage(filePatch: URL) -> ProcessingResult {
//        do {
//            let data = try Data(contentsOf: filePatch)
//            let extention = filePatch.pathExtension
//            return ProcessingResult.image(imageData: data, extention: extention)
//            
//        } catch {
//            return ProcessingResult.error(description: "Image not available")
//        }
//    }
    
   
    
    
    
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
