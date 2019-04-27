//
//  FreeAccountsHendler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/04/2019.
//

import Vapor

class CloudinaryAccountsHandler {
    
    let sqlHandler = SQLHandler()
    
    let storageApiUrl = "http://localhost:8081/"
    //let storageApiUrl = "https://nnnstorage.herokuapp.com/"
    let allUrlPatameter = "all/"
    let allByTitleUrlParameter = "allByTitle/"
    let lastByTitleUrlParameter = "lastByTitle/"
    let byIDUrlParameter = "byID/"
    let recordUrlParameter = "record/"
    let title = "CloudinaryStatus_"

    
    // newDayStatusUpdate
    
    public func newDayStatusUpdate(_ req: Request) throws {
        
        let a = try getAllAccounts(req)
            .map { accounts in
                for account in accounts {
                    
                    let currentTitle = self.title + account.userName
                    
                    let result = try self.getStatusOf(account: account, req)
                        .map { json in
                            try self.writeToDB(title: currentTitle, jsonData: json, req)
                    }
                    
                    
                }
            }
    }
    
    
    
    private func getAllAccounts(_ req: Request) throws -> Future<[ServiceData]> {
        return try sqlHandler.getServiceDataBy(serviceName: "Cloudinary", req)
    }

    
    
    private func getStatusOf(account: ServiceData, _ req: Request) throws -> Future<String> {
        
        let url = "https://\(account.apiKey):\(account.apiSecret)@api.cloudinary.com/v1_1/\(account.userName)/usage"

        return try req.client().get(url).map { res -> String in
            return res.http.body.description
        }
    }
    
    
    // Store JSON in DB
    
    // Clean chache if it needed
    
    // Store all working accounts list in DB
    
    
    
    //============
    // Read from DB
    private func readAllFromDB(title: String, _ req: Request) throws -> Future<[HerokuStorage]>  {
        let url = storageApiUrl + allByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { res in
                return try res.content.decode([HerokuStorage].self)
        }
    }
    
    
    private func readLastFromDB(title: String, _ req: Request) throws -> Future<HerokuStorage> {
        let url = storageApiUrl + lastByTitleUrlParameter + title
        
        return try req.client()
            .get(url)
            .flatMap { res in
                return try res.content.decode(HerokuStorage.self)
        }
    }
    
    
    private func writeToDB(title: String, jsonData: String, _ req: Request) throws -> Future<Response> {
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let newRecord = HerokuStorage(title: title, unixTime: timestamp, data: jsonData)
        let url = storageApiUrl + recordUrlParameter
        
        return try req.client().post(url) { res in
            try res.content.encode(newRecord)
        }
    }
    
    
}
