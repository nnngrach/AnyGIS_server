//
//  ImageProcessor.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor

class ImageProcessor {
    
    let paralleliser = FreeAccountsParalleliser()
    
    
    //MARK: Generate filename
    
    private func makeName(_ sourceUrl: String) -> String {
        
        var range: Range<String.Index>
        let yandexNarodMapUrlLenght = 580
        let serverPartOffset = 13
        let prefix = "img"
        
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
        return prefix + filenameString
    }
    
    
    
    
    //MARK: Uploading image to Cloudinary server
    
    public func uploadOneTile(_ sourceUrl: String, _ sessionID: String, _ request: Request) throws -> Future<Response> {
        
        let host = "https://api.cloudinary.com/v1_1/anygis" + sessionID + "/image/upload"
        let name = makeName(sourceUrl)
        
        let message = CloudinaryPostMessage(file: sourceUrl,
                                            public_id: name,
                                            upload_preset: "guestPreset")
        
        let postResponse = try request.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
        
        return postResponse
    }
    
    
    
    public func uploadTwoTiles(_ sourceUrls: [String], _ sessionID: String, _ request: Request) throws -> [Future<Response>] {
        
        let baseResponce = try uploadOneTile(sourceUrls[0], sessionID, request)
        let overlayResponce = try uploadOneTile(sourceUrls[1], sessionID, request)
        
        return [baseResponce, overlayResponce]
    }
    
    
    
    public func uploadFourTiles(_ sourceUrls: [String], _ sessionID: String, _ request: Request) throws -> [Future<Response>] {
        
        let tlLoadingResponce = try uploadOneTile(sourceUrls[0], sessionID, request)
        let trLoadingResponce = try uploadOneTile(sourceUrls[1], sessionID, request)
        let brLoadingResponce = try uploadOneTile(sourceUrls[2], sessionID, request)
        let blLoadingResponce = try uploadOneTile(sourceUrls[3], sessionID, request)
        
        return [tlLoadingResponce, trLoadingResponce, brLoadingResponce, blLoadingResponce]
    }
    
    
    
    
    //MARK: Synchronizing Responces
    
    public func syncOne(_ loadingResponce: EventLoopFuture<Response>,
                        _ req: Request,
                        _ closure: @escaping (Request) -> (EventLoopFuture<Response>)) -> EventLoopFuture<Response> {
        
        
        return loadingResponce.flatMap(to: Response.self) { _ in
            //Body
            return closure(req)
        }
    }
    
    
    
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
    
    
    
    
    
    //MARK: Generating URL to Cloudinary image
    
    public func getUrlOverlay(_ baseUrl: String, _ overlayUrl: String, _ sessionID: String) -> String {
        let baseImgName = makeName(baseUrl)
        let overlayImgName = makeName(overlayUrl)
       
        return "https://res.cloudinary.com/anygis\(sessionID)/image/upload/l_\(overlayImgName)/\(baseImgName)"
    }
    
    
    
    public func getUrlWithOffset(_ urls: [String], _ offsetX: Int, _ offsetY: Int, _ sessionID: String ) -> String {
        let topLeft = makeName(urls[0])
        let topRight = makeName(urls[1])
        let bottomRight = makeName(urls[2])
        let bottomLeft = makeName(urls[3])
       
        return "https://res.cloudinary.com/anygis\(sessionID)/image/upload/l_\(topLeft),y_-256/l_\(topRight),x_256,y_-128/l_\(bottomRight),x_128,y_128/c_crop,g_north_west,w_256,h_256,x_\(offsetX),y_\(offsetY)/\(bottomLeft)"
    }
    
    
    
    public func getUrlWithOffsetAndOverlay(_ urls: [String], _ overlayUrl: String, _ offsetX: Int, _ offsetY: Int, _ sessionID: String  ) -> String {
        let topLeft = makeName(urls[0])
        let topRight = makeName(urls[1])
        let bottomRight = makeName(urls[2])
        let bottomLeft = makeName(urls[3])
        let overlay = makeName(overlayUrl)
      
        return "https://res.cloudinary.com/anygis\(sessionID)/image/upload/l_\(topLeft),y_-256/l_\(topRight),x_256,y_-128/l_\(bottomRight),x_128,y_128/c_crop,g_north_west,w_256,h_256,x_\(offsetX),y_\(offsetY)/l_\(overlay),o_100/\(bottomLeft)"
    }
    
    
    
    
    public func getUrlWithOffsetAndDoubleOverlay(_ urls: [String], _ overlayUrls: [String], _ offsetX: Int, _ offsetY: Int, _ sessionID: String  ) -> String {
        let topLeft = makeName(urls[0])
        let topRight = makeName(urls[1])
        let bottomRight = makeName(urls[2])
        let bottomLeft = makeName(urls[3])
        
        let overTopLeft = makeName(overlayUrls[0])
        let overTopRight = makeName(overlayUrls[1])
        let overBottomRight = makeName(overlayUrls[2])
        let overBottomLeft = makeName(overlayUrls[3])
        
        return "https://res.cloudinary.com/anygis\(sessionID)/image/upload/l_\(topLeft),y_-256/l_\(topRight),x_256,y_-128/l_\(bottomRight),x_128,y_128/l_\(overTopLeft),x_-128,y_-128/l_\(overTopRight),x_128,y_-128/l_\(overBottomLeft),x_-128,y_128/l_\(overBottomRight),x_128,y_128/c_crop,g_north_west,w_256,h_256,x_\(offsetX),y_\(offsetY)/\(bottomLeft)"
    }
    
    
}
