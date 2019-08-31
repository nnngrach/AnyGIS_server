//
//  StravaParser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 13/04/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor

class StravaParser {
    
    private let cookieExtractorApi = "http://68.183.65.138:5050/StravaAuth/"
    
    
    //private let startCookieExtractorScriptUrl = "https://api.apify.com/v2/acts/nnngrach~strava-auth/run-sync?token=ATnnxbF6sE7zEZDmMbZTTppKo&outputRecordKey=OUTPUT&timeout=120"
    
    //private let fetchedDataUrl = "https://api.apify.com/v2/acts/nnngrach~strava-auth/runs/last/dataset/items?token=ATnnxbF6sE7zEZDmMbZTTppKo"
    
    
    // for temporary urls bugfix
    // don'd use after 1.08.19
//    private let startCookieExtractorScriptUrl = "https://api.apify.com/v2/acts/9qaEDAaykK4zDQiHd/run-sync?token=kbcPyhW2wGwoj86ADpwW8b4WZ&outputRecordKey=OUTPUT&timeout=120"
//
//    private let fetchedDataUrl = "https://api.apify.com/v2/acts/9qaEDAaykK4zDQiHd/runs/last/dataset/items?token=kbcPyhW2wGwoj86ADpwW8b4WZ"
    
    
    
    
    
    
    
    public func getAuthParameters(login: String, password: String, _ req: Request) throws -> Future<String> {
        
        var resultHttpParameters = ""
        
        let stravaAutherUrl = cookieExtractorApi + login + "/" + password
       
        let authedCookieResponse = try req.client().get(stravaAutherUrl)
       
        
        
        
        let resultingHttpParameters = authedCookieResponse.map(to: String.self) { res in
            
            let resonseWithCookies = "\(res.http.body)"
            
        
            if let decodedCookies = try? JSONDecoder().decode([StravaOutputJson].self, from: resonseWithCookies) {
                
                var isFoundedCloudFront = false
                
                for cookie in decodedCookies {
                    
                    if cookie.name.hasPrefix("CloudFront") {
                        
                        isFoundedCloudFront = true
 
                        let parametrName = cookie.name.replacingOccurrences(of: "CloudFront-", with: "")
                        
                        resultHttpParameters.append("&" + parametrName + "=" + cookie.value)
                    }
                }
                
                if !isFoundedCloudFront { return "Error: wrong parsing cookies" }
                
                
            } else {
                fatalError("Error with Strava JSON decoding")
            }
            
            return resultHttpParameters
        }
        
        return resultingHttpParameters
        
    }
    
    

}
