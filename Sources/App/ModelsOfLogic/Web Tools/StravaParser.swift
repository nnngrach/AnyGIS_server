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
//    private let cookieExtractorApi = "http://localhost:4000/StravaAuth/"
    
    
    
    
    public func fetchNewAuthParameters(login: String, password: String, _ req: Request) throws -> Future<String> {
        
        var resultHttpParameters = ""
        
        let stravaAutherUrl = cookieExtractorApi + login + "/" + password
       
        let authedCookieResponse = try req.client().get(stravaAutherUrl)
       
        
        
        
        let resultingHttpParameters = authedCookieResponse.map(to: String.self) { res in
            
            var resonseWithCookies = "\(res.http.body)"
            
            //print("result :", resonseWithCookies)
            resultHttpParameters = resonseWithCookies
            //resultHttpParameters = try self.parseCookies(resonseWithCookies)
            
            if (self.isContainsAllNeededParamsIn(resultHttpParameters))
            {
                return resultHttpParameters
            } else
            {
                throw(GlobalErrors.parsingFail)
            }
        }
        
        return resultingHttpParameters
    }
    
    
    private func parseCookies(_ cookies: String) throws -> String {
        
        var parsedNewHttpAtuthParams = ""
        
        if let decodedCookies = try? JSONDecoder().decode([StravaOutputJson].self, from: cookies) {
            
            var isFoundedCloudFront = false
            
            for cookie in decodedCookies {
                
                if cookie.name.hasPrefix("CloudFront") {
                    
                    isFoundedCloudFront = true

                    let parametrName = cookie.name.replacingOccurrences(of: "CloudFront-", with: "")
                    
                    parsedNewHttpAtuthParams.append("&" + parametrName + "=" + cookie.value)
                }
            }
            
            if !isFoundedCloudFront {
                print("Error: wrong parsing cookies")
                throw(GlobalErrors.parsingFail)
            }
            
        } else {
            print("Error with Strava JSON decoding")
            throw(GlobalErrors.parsingFail)
        }
        
        return parsedNewHttpAtuthParams
    }

    private func isContainsAllNeededParamsIn(_ params: String) -> Bool {
        return params.contains("Signature") && params.contains("Key-Pair-Id") && params.contains("Policy")
    }
}
