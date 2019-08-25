//
//  FreeAccountsHendler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/04/2019.
//

import Vapor

class CloudinaryAccountsHandler {
    
    let sqlHandler = SQLHandler()
    let casheHandler = CloudinaryCasheHandler()
    let externalStorage = ExternalStorageHandler()
    
    let titleIntro = "CloudinaryStatus_"

    
    
    public func newDayStatusUpdate(_ req: Request) throws {
        
        try clearWorkingAccountsList(req)
        
        
        try getAllAccountsInfo(req).map { accounts in
                
            for account in accounts {
                
                let currentTitle = self.titleIntro + account.userName
                
                try self.getStatusOf(account: account, req).map { responseJson in
                    
                    //logging with another heroku account
                    //try self.externalStorage.writeToDB(title: currentTitle, jsonData: responseJson, req)
                    
                    let decodedJson = try JSONDecoder().decode(CloudinaryUsage.self, from: responseJson)
                    
                    try self.addWorkingAccountToList(decodedJson, account, req)
                    
                    try self.casheHandler.erase(account, decodedJson, req)
                }
            }
        }
    }
    
    
    
 
    
    
    private func getAllAccountsInfo(_ req: Request) throws -> Future<[ServiceData]> {
        return try sqlHandler.getServiceDataBy(serviceName: "Cloudinary", req)
    }

    
    
    private func getStatusOf(account: ServiceData, _ req: Request) throws -> Future<String> {
        
        let url = "https://\(account.apiKey):\(account.apiSecret)@api.cloudinary.com/v1_1/\(account.userName)/usage"

        return try req.client().get(url).map { res -> String in
            return res.http.body.description
        }
    }
    
    
    
    private func addWorkingAccountToList(_ json: CloudinaryUsage, _ account: ServiceData, _ req: Request) throws {

        if json.credits.used_percent < 70 {
            let accountNumber = account.userName.replacingOccurrences(of: "anygis", with: "")
            try appendToWorkingAccountsList(accountNumber + ";", req)
        }
    }
    
    
    private func clearWorkingAccountsList(_ req: Request) throws {
       
        try sqlHandler.getServiceDataBy(serviceName: "CloudinaryWorkedAccountsList", req)
            .map { record in
                record[0].apiSecret = ""
                record[0].save(on: req)
        }
    }
    
    
    private func appendToWorkingAccountsList(_ content: String, _ req: Request) throws {
        
        try sqlHandler.getServiceDataBy(serviceName: "CloudinaryWorkedAccountsList", req)
            .map { record in
                record[0].apiSecret = record[0].apiSecret + content
                record[0].save(on: req)
        }
    }
  
}
