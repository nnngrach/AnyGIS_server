//
//  CasheHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation
import Vapor


class CasheHandler {
    
    public func erase(_ req: Request) throws {
        
        //try checkImageCount(req)
        
        guard isCleaningTime() else {return}
        
        
        // Check uploaded count
        // Erase uploaded
        
        // Check fetched count
        // Erase fetched
        
        
        //try uploadOneTile("https://a.tile.openstreetmap.org/0/0/0.png", "0", req)
    }
    
    
    // Cloudinary cashe will be cleaning
    // at the 1-st day of every month.
    private func isCleaningTime() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return day == 1
    }

    
    private func checkImageCount(_ url: String, _ req: Request) throws -> Future<Int> {
        let url2 = "https://399359168177684:ZFECQbQhvPKH2t4Dvq0zTwvqBBY@api.cloudinary.com/v1_1/anygis0/resources/search?expression=type:fetch"
        
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
    
    
    
    
//    private func uploadOneTile(_ sourceUrl: String, _ sessionID: String, _ request: Request) throws{
//
//        let host = "https://api.cloudinary.com/v1_1/anygis" + sessionID + "/image/upload"
//        let name = "img_testingTimer_" + String(NSDate().timeIntervalSince1970)
//
//        let message = CloudinaryPostMessage(file: sourceUrl,
//                                            public_id: name,
//                                            upload_preset: "guestPreset")
//
//        let postResponse = try request.client().post(host) { postReq in
//            try postReq.content.encode(message)
//        }
//    }
    
    
}
