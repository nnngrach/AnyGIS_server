//
//  HttpFunctions.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 04/02/2019.
//

import Foundation
import Vapor

class OutputResponceGenerator {
    
    public func errorResponce (_ description: String, _ req: Request) throws -> Future<Response> {
        
        throw Abort(.internalServerError, reason: description)
    }
    
    
    public func notFoundResponce (_ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .notFound, body: "")).encode(for: req)
    }
    
    
    public func redirect(to url: String, with req: Request) -> Future<Response>  {
        return try! req.redirect(to: url).encode(for: req)
    }
}
