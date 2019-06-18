//
//  MapProcessorNavionics.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 07/05/2019.
//


import Vapor

class MapProcessorStrava: AbstractMapProcessorSimple {
    
    let paralelliser = FreeAccountsParalleliser()
    let stravaParser = StravaParser()
    
    
    override func makeCustomActions(_ mapName:String, _ tileNumbers: (x: Int, y: Int, z: Int), _ tilePosition: (x: Int, y: Int, offsetX: Int, offsetY: Int)?, _ mapObject: (MapsList), _ baseObject: (MapsList)?, _ overlayObject: (MapsList)?,   _ cloudinarySessionID: String?, _ req: Request) throws -> EventLoopFuture<Response> {
        

        let isInAuthProcessingStausText = "The app is processing Strava authorization. Please reload this map after 2 minutes"
        
        
        var generatedUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject.backgroundUrl, mapObject.backgroundServerName)
        
        
        let currentStravaSession = paralelliser.getStravaSessionId()
        
        let storedStravaAuthData = try sqlHandler.getServiceDataBy(serviceName: currentStravaSession, req)
        
        var futureUrl: Future<String> = req.future("")
        
        
        let resultResponse = storedStravaAuthData.flatMap(to: Response.self) { data in
            
            let storedStravaAuthLine = data[0]
            
            
            // Final URL as a future
            futureUrl = futureUrl.flatMap(to: String.self) {_ in
                
                // Load free version of map (/tiles/)
                if tileNumbers.z < 12 {
                    
                    generatedUrl = generatedUrl.replacingOccurrences(of: "tiles-auth", with: "tiles")
                    
                    return req.future(generatedUrl)
                    
                    
                    // Load map with auth parameters (/tiles-auth/)
                } else {
                    
                    // Stop if is in auth processing now
                    guard storedStravaAuthLine.apiSecret != isInAuthProcessingStausText else {return req.future(isInAuthProcessingStausText)}
                    
                    
                    let urlWithStoredAuthKey = generatedUrl + storedStravaAuthLine.apiSecret
                    
                    let checkedStatus = try self.urlChecker.checkUrlStatusAndProxy(urlWithStoredAuthKey, nil, nil, req)
                    
                    
                    // Checking stored AuthKey
                    let futureUrlWithWorkingAuthKey = checkedStatus.flatMap(to: String.self) { status in
                        
                        // Key is valid. Return the same URL
                        if status.code == 200 {
                            
                            return req.future(urlWithStoredAuthKey)
                            
                            // Key is invalid. Fetching new key. Return URL with new key
                        } else {
                            
                            // Add stopper-flag
                            storedStravaAuthLine.apiSecret = isInAuthProcessingStausText
                            storedStravaAuthLine.save(on: req)
                            
                            
                            let stravaAuthParams = try self.stravaParser.getAuthParameters(login: storedStravaAuthLine.userName, password: storedStravaAuthLine.apiKey, id: cloudinarySessionID!, req)
                            
                            let futureUrlWithNewAuthKey = stravaAuthParams.map(to: String.self) { newParams in
                                
                                storedStravaAuthLine.apiSecret = newParams
                                storedStravaAuthLine.save(on: req)
                                
                                return generatedUrl + newParams
                            }
                            
                            return futureUrlWithNewAuthKey
                        }
                    }
                    
                    return futureUrlWithWorkingAuthKey
                }
            }
            
            
            // Redirecting user to checked URL
            let response = futureUrl.map(to: Response.self){ resultUrl in
                
                guard resultUrl != isInAuthProcessingStausText else {return self.output.customErrorResponce(501, isInAuthProcessingStausText, req)}
                
                return req.redirect(to: resultUrl)
            }
            
            return response
        }
        
        
        return resultResponse
    }
    
}

