//
//  Request.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 24/02/2019.
//

import Vapor

extension Request {
    public func response(file: File) -> Response {
        let headers: HTTPHeaders = [
            "content-disposition": "attachment; filename=\"\(file.filename)\""
        ]
        let res = HTTPResponse(headers: headers, body: file.data)
        return response(http: res)
    }
}
