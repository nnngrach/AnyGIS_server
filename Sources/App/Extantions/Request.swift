//
//  Request.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Vapor

extension Request {
    func response(file: File) -> Response {
        let headers: HTTPHeaders = [
            "content-disposition": "attachment; filename=\"\(file.filename)\""
        ]
        let res = HTTPResponse(headers: headers, body: file.data)
        return response(http: res)
    }
}
