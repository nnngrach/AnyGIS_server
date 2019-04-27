//
//  ExternalStorageHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 27/04/2019.
//

import Vapor

class ExternalStorageHandler {
    
    //let storageApiUrl = "http://localhost:8081/"
    
    let storageApiUrl = "https://nnnstorage.herokuapp.com/"
    let allUrlPatameter = "all/"
    let allByTitleUrlParameter = "allByTitle/"
    let lastByTitleUrlParameter = "lastByTitle/"
    let byIDUrlParameter = "byID/"
    let recordUrlParameter = "record/"
    
    
    public func readAllFromDB(title: String, _ req: Request) throws -> Future<[HerokuStorage]>  {
        
        let url = storageApiUrl + allByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { res in
                return try res.content.decode([HerokuStorage].self)
        }
    }
    
    
    
    
    public func readLastFromDB(title: String, _ req: Request) throws -> Future<HerokuStorage> {
        let url = storageApiUrl + lastByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { res in
                return try res.content.decode(HerokuStorage.self)
        }
    }
    
    
    
    public func writeToDB(title: String, jsonData: String, _ req: Request) throws -> Future<Response> {
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let newRecord = HerokuStorage(title: title, unixTime: timestamp, data: jsonData)
        let url = storageApiUrl + recordUrlParameter
        
        return try req.client().post(url) { res in
            try res.content.encode(newRecord)
        }
    }
}
