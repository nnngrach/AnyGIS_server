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

                print("Error with Strava JSON decoding")
                print(login)
                print(resonseWithCookies)
                throw(GlobalErrors.parsingFail)
            }
            
            return resultHttpParameters
        }
        
        return resultingHttpParameters
        
    }
    
    

}
