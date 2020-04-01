//
//  CasheHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation
import Vapor


class CloudinaryCasheHandler {
    
    let sqlHandler = SQLHandler()
    let deletingPerTimeLimit = 1000
    
    
    
    func erase(_ account: ServiceData, _ stats: CloudinaryUsage, _ req: Request) throws {
        
        let imagesCountInStorage = stats.objects.usage
        
        if imagesCountInStorage > deletingPerTimeLimit {
            
            try checkAndDeleteFromFolder("fetch", account, req)
            
            try checkAndDeleteFromFolder("upload", account, req)
        }
    }
    
    
    
    
    private func checkAndDeleteFromFolder(_ folder: String, _ account: ServiceData, _ req: Request) throws {
        
        let futureImageCount = try self.checkImageCount(account.userName, account.apiKey, account.apiSecret, folder, req)
        
        let _ = futureImageCount.map { imageCount in
            
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
        
        let _ = try req.client().delete(url)
    }
    
}
