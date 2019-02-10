//
//  CasheHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation
import Vapor


class CasheHandler {
    
    let sqlHandler = SQLHandler()
    let deletingPerTimeLimit = 1000
    
    
    public func erase(_ req: Request) throws {
        
        guard isCleaningTime() else {return}
        
        try sqlHandler
            .getServiceDataBy(serviceName: "Cloudinary", req)
            .map { data in
                
                for account in data {
                    try self.checkAndDeleteFromFolder("fetch", account, req)
                    try self.checkAndDeleteFromFolder("upload", account, req)
                }
        }
    }
    
    
    
    
    // Cloudinary cashe will be cleaning
    // at the 1-st day of every month.
    private func isCleaningTime() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return day == 1
    }
    
    
    
    private func checkAndDeleteFromFolder(_ folder: String, _ account: ServiceData, _ req: Request) throws {
        
        let futureImageCount = try self.checkImageCount(account.userName, account.apiKey, account.apiSecret, folder, req)
        
        futureImageCount.map { imageCount in
            
            let needDeleteOperations = imageCount / self.deletingPerTimeLimit
            
            for _ in 0 ..< needDeleteOperations {
                try self.deleteImages(account.userName, account.apiKey, account.apiSecret, folder, req)
            }
        }
    }

    
    
    
    private func checkImageCount(_ account: String, _ apiKey: String, _ apiSecret: String, _ folder: String, _ req: Request) throws -> Future<Int> {
        
        let url = "https://\(apiKey):\(apiSecret)@api.cloudinary.com/v1_1/\(account)/resources/search?expression=type:\(folder)"
        
        let res = try req.client().get(url)

        let count = res.flatMap(to: Int.self) { resData in
            
            return try resData
                .content
                .decode(CloudinarySesrchResponse.self)
                .map(to: Int.self) { jsonContent in
                    
                    return jsonContent.total_count
            }
        }
        
        return count
    }
    
    
    
    
    private func deleteImages(_ account: String, _ apiKey: String, _ apiSecret: String, _ folder: String, _ req: Request) throws {
        
        let url = "https://\(apiKey):\(apiSecret)@api.cloudinary.com/v1_1/\(account)/resources/image/\(folder)?all=true"
        
        try req.client().delete(url)
    }
    
}
