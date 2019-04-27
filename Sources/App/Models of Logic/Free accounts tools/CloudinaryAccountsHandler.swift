//
//  FreeAccountsHendler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/04/2019.
//

import Vapor

class CloudinaryAccountsHandler {
    
    let storageApiUrl = "http://localhost:8081/"
    //let storageApiUrl = "https://nnnstorage.herokuapp.com/"
    let allUrlPatameter = "all/"
    let allByTitleUrlParameter = "allByTitle/"
    let lastByTitleUrlParameter = "lastByTitle/"
    let byIDUrlParameter = "byID/"
    let recordUrlParameter = "record/"

    
    // newDayStatusUpdate
    
    
    // Get all accounts list
    
    // Check account status
    
    // Store JSON in DB
    
    // Clean chache if it needed
    
    // Store all working accounts list in DB
    
    
    
    //============
    // Read from DB
    func readAllFromDB(title: String, _ req: Request) throws -> Future<[HerokuStorage]>  {
        let url = storageApiUrl + allByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { response in
                return try response.content.decode([HerokuStorage].self)
        }
    }
    
    
    func readLastFromDB(title: String, _ req: Request) throws -> Future<HerokuStorage> {
        let url = storageApiUrl + lastByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { response in
                return try response.content.decode(HerokuStorage.self)
        }
    }
    
    
    func writeToDB(title: String, jsonData: String, _ req: Request) throws -> Future<Response> {
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let newRecord = HerokuStorage(title: title, unixTime: timestamp, data: jsonData)
        let url = storageApiUrl + recordUrlParameter
        
        return try req.client().post(url) { response in
            try response.content.encode(newRecord)
        }
    }
    
    
}
