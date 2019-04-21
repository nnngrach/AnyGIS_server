//
//  StravaParser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 13/04/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor

class StravaParser {
    
    private let startCookieExtractorScriptUrl = "https://api.apify.com/v2/acts/nnngrach~strava-auth/run-sync?token=ATnnxbF6sE7zEZDmMbZTTppKo&outputRecordKey=OUTPUT&timeout=120"
    
    private let fetchedDataUrl = "https://api.apify.com/v2/acts/nnngrach~strava-auth/runs/last/dataset/items?token=ATnnxbF6sE7zEZDmMbZTTppKo"
    

    
    
    public func getAuthParameters(login: String, password: String, _ req: Request) throws -> Future<String> {
        
        var httpParameters = ""
        
        let loginRequest = StravaLoginRequest(email: login, password: password)
        
        
        let starterCookieExtractResponse = try req.client().post(startCookieExtractorScriptUrl) { loginReq in
            try loginReq.content.encode(loginRequest)
        }
        
        
        let loaderSavedCookieResponse = starterCookieExtractResponse.flatMap(to: Response.self) { res in
            return try req.client().get(self.fetchedDataUrl)
        }
        
        
        
        let resultingHttpParameters = loaderSavedCookieResponse.map(to: String.self) { res in
            
            let resonseWithCookies = "\(res.http.body)"
            
            
            if let decodedCookies = try? JSONDecoder().decode([StravaOutputJson].self, from: resonseWithCookies) {
                
                for cookie in decodedCookies {
                    
                    if cookie.name.hasPrefix("CloudFront") {
                        
                        let parametrName = cookie.name.replacingOccurrences(of: "CloudFront-", with: "")
                        
                        httpParameters.append("&" + parametrName + "=" + cookie.value)
                    }
                }
                
            } else {
                
                fatalError("Error with Strava JSON decoding")
                
            }
            
            
            return httpParameters
        }
        
        
        return resultingHttpParameters
    }
    
}
