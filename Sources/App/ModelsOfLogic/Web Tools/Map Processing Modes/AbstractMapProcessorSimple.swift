//
//  AbstractMapProcessorSimple.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 28/04/2019.
//

import Vapor

class AbstractMapProcessorSimple {
    
    let coordinateTransformer = CoordinateTransformer()
    let paralleliser = FreeAccountsParalleliser()
    let urlPatchCreator =  URLPatchCreator()
    let output = OutputResponceGenerator()
    let cloudinaryImageProcessor = CloudinaryImageProcessor()
    let imageProcessor = ImageProcessor()
    let urlChecker = UrlFIleChecker()
    let sqlHandler = SQLHandler()
    
    init() {
        //urlChecker.delegate = webHandler
    }
    
    
    // This part is repeating for some modes
    
    public func process(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ mapObject: (MapsList), _ req: Request) throws -> EventLoopFuture<Response> {
        
        return try makeCustomActions(mapName, tileNumbers, nil, mapObject, nil, nil, nil, req)
    }
    
    
    // This part is unically for every mode
    
    func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        
        return req.future(Response(http: HTTPResponse(status: .notFound), using: req))
    }
    
}
