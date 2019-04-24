//
//  HttpFunctions.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 04/02/2019.
//

import Foundation
import Vapor

class OutputResponceGenerator {
    
    public func serverErrorResponce (_ description: String, _ req: Request) throws -> Future<Response> {
        
        throw Abort(.internalServerError, reason: description)
    }
    
    
    public func customErrorResponce (_ statusCode: Int, _ description: String, _ req: Request) -> Response {
        
        return Response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: statusCode, reasonPhrase: description)), using: req)
    }
    
    
    public func notFoundResponce (_ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .notFound, body: "")).encode(for: req)
    }
    
    
    public func redirect(to url: String, with req: Request) -> Future<Response>  {
        return try! req.redirect(to: url).encode(for: req)
    }
    
    
    public func redirectWithReferer(to url: String, referer: String?, with req: Request) -> Future<Response>  {
        let resultReferer = referer ?? "https://anygis.herokuapp.com/"
        
        return try! req.client().get(url, headers: HTTPHeaders(dictionaryLiteral: ("referer",resultReferer)))
    }
    
}
