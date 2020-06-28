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
        
//        print("!!! 0 - Start")
        let isInAuthProcessingStausText = "The app is processing Strava authorization. Please reload this map after 2 minutes"
        
        var futureUrl: Future<String> = req.future("")
        
        var generatedUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, tileNumbers.z, mapObject)
        
    
        let storedStravaAuthCookies = try sqlHandler.getServiceDataBy(serviceName: "TempCookieStrava", req)
        
       
        
        let resultResponse = storedStravaAuthCookies.flatMap(to: Response.self) { data in
            
            let storedStravaAuthLine = data[0]
//            print("!!! 1 - Extract db")
            
            // Final URL as a future
            futureUrl = futureUrl.flatMap(to: String.self) {_ in
//                print("!!! 2 - Sync db")
                // Load free version of map (/tiles/)
                if tileNumbers.z < 12 {
//                    print("!!! 3 - Low zoom")
                    generatedUrl = generatedUrl.replacingOccurrences(of: "tiles-auth", with: "tiles")
                    
                    return req.future(generatedUrl)
                    
                    
                // Load map with auth parameters (/tiles-auth/)
                } else {
//                    print("!!! 4 - Hight zoom")
                    
                    // Redirect to Nakarte Strava mirror
//                    guard storedStravaAuthLine.apiSecret != isInAuthProcessingStausText else {
//                        return req.future(self.getMirrorUrl(tileNumbers: tileNumbers, urlTemplate: mapObject.backgroundUrl))
//                    }
                    
//                    guard storedStravaAuthLine.apiSecret != isInAuthProcessingStausText else {
//                        return req.response(http: HTTPResponse(status: HTTPResponseStatus(statusCode: 500)))
//                    }
                    
                    guard !self.isNeedToWaitFrom(scrtiptStartTime: storedStravaAuthLine.apiSecret) else {return req.future(isInAuthProcessingStausText)}
//                    print("!!! 5 - No need to wait")
                    
                    
                    let urlWithStoredAuthKey = generatedUrl + storedStravaAuthLine.apiSecret
                    
                    let checkedStatus = try self.urlChecker.checkUrlStatusAndProxy(urlWithStoredAuthKey, nil, nil, req)
                    
                    
                    // Checking stored AuthKey
                    let futureUrlWithWorkingAuthKey = checkedStatus.flatMap(to: String.self) { status in
//                        print("!!! 6 - checkedURLStatus ", status)
                        
                        // Key is valid. Return the same URL
                        if status.code == 200 {
//                            print("!!! 7 - status valid")
                            return req.future(urlWithStoredAuthKey)
                        
                            
                        // Key is invalid. Fetching new key. Return URL with new key
                        } else {
//                            print("!!! 8 - status invalid")
                            // Add stopper-flag
                            storedStravaAuthLine.apiSecret = String(Date().timeIntervalSince1970)
                            storedStravaAuthLine.save(on: req)
//                            storedStravaAuthLine.apiSecret = isInAuthProcessingStausText
                            let _ = storedStravaAuthLine.save(on: req)
 
                           
                            let accountsData = self.sqlHandler.fetchServiceList(req)
                            
        
                            let authedParams = accountsData.flatMap(to: String.self) { accounts in
                                
                                let stravaAccouts = accounts.filter {$0.serviceName.hasPrefix("Strava")}
//                                print("!!! 9 - Fetched Strava accouns", stravaAccouts)
                                return try self.recursiveStravaAuth(interanionNumber: 0, accounts: stravaAccouts, req: req)
                            }
                                
                                
                        
                            let futureUrlWithNewAuthKey = authedParams.map(to: String.self) { newParams in
                                
                                storedStravaAuthLine.apiSecret = newParams
                                let _ = storedStravaAuthLine.save(on: req)
//                                print("!!! 10 - new param ", newParams)
                                return generatedUrl + newParams
                            }
                            
                            return futureUrlWithNewAuthKey
                        }

                    }
                    
                    return futureUrlWithWorkingAuthKey
                }
            }
            
            
            // Redirecting user to checked URL
            let response = futureUrl.flatMap(to: Response.self){ resultUrl in
                
                guard resultUrl != isInAuthProcessingStausText else {
                    return req.future(self.output.customErrorResponce(501, isInAuthProcessingStausText, req))
//                    print("!!! 11 - isInAuthProcessingStausText")
//                    return req.future(Response(http: HTTPResponse(status: .ok, body: isInAuthProcessingStausText), using: req))
                }
                
                // AlpineQuest app can't handle 303 redirect.
                // So, maps for it marked with suffix "proxy"
                // to use special mode
//                print("!!! 12 - Get ", resultUrl)
//                if true {
                if mapName.hasSuffix("proxy") {
                    return try req.client().get(resultUrl)
                        .catchMap { error in
                             let errorText = error.localizedDescription + "\n" + req.description
                             return Response(http: HTTPResponse(status: .ok, body: errorText), using: req)
                        }
                } else {
                // Regular mode
                    return req.future(req.redirect(to: resultUrl))
                        .catchMap { error in
                            let errorText = error.localizedDescription + "\n" + req.description
                            return Response(http: HTTPResponse(status: .ok, body: errorText), using: req)
                        }
                }
            }
            
            return response
        }
        
        
        return resultResponse
     }
    
    
    
    
    
    // Try to log in with all Strava accounts
    // Some of them can be blocked
    
    func recursiveStravaAuth(interanionNumber: Int, accounts: [ServiceData], req: Request) throws -> Future<String> {
        
        guard interanionNumber <= accounts.count else { return req.future("All_Strava_accounts_can't_log_in") }
        
        let randomNumber = randomNubmerForHeroku(accounts.count)
        let randomAccount = accounts[randomNumber]
        
        
        do {
            
            let stravaAuthParams = try stravaParser.getAuthParameters(login: randomAccount.userName, password: randomAccount.apiKey, req)
            
            let checkedResult = stravaAuthParams.flatMap(to: String.self) { params in
                
                //correct cookie has "Signature" field
                if params.contains("&Signature") {
                    return req.future(params)
                    
                } else {
                    return try self.recursiveStravaAuth(interanionNumber: interanionNumber + 1, accounts: accounts, req: req)
                }
            }
            
            return checkedResult
            
        } catch {
            
            return try self.recursiveStravaAuth(interanionNumber: interanionNumber + 1, accounts: accounts, req: req)
        }
    }
    
    
    
    func isNeedToWaitFrom(scrtiptStartTime: String) -> Bool {
//        print("$$$$ scrtiptStartTime ", scrtiptStartTime)
        let periodToWait = 90 // sec
        
        // check on text or empty value
        guard let storedTime = Double(scrtiptStartTime) else { return false }

        let currentTimeStamp = Double(Date().timeIntervalSince1970)
        let currentPeriod = currentTimeStamp - storedTime
        
        return Int(currentPeriod) < Int(periodToWait)
    }
    
    
    
    private func getMirrorUrl(tileNumbers: (x: Int, y: Int, z: Int), urlTemplate: String) -> String {
        
        let mirrorUrl = "https://proxy.nakarte.me/https/heatmap-external-b.strava.com/tiles-auth/all/hot/{z}/{x}/{y}.png?px=512"
        
        var resultUrl = mirrorUrl.replacingOccurrences(of: "/all/hot/{", with: getMapMode(urlTemplate))

        resultUrl = resultUrl.replacingOccurrences(of: "{z}/{x}/{y}", with: "\(tileNumbers.z)/\(tileNumbers.x)/\(tileNumbers.y)")
        
        resultUrl = resultUrl.replacingOccurrences(of: "=512", with: getTileSize(urlTemplate))
                
        return resultUrl
    }
    
    
    
    private func getMapMode(_ urlTemplate: String) -> String {
        do {
            
            let regex = try NSRegularExpression(pattern: "tiles-auth(.*)z", options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: urlTemplate, options: [], range: NSRange(location: 0, length: urlTemplate.utf16.count))

            if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: urlTemplate) {
                    return String(urlTemplate[swiftRange])
                }
            }
            
        } catch {}
        
        return urlTemplate
    }
    
    
    private func getTileSize(_ urlTemplate: String) -> String {
        let tileSizeIndex = urlTemplate.firstIndex(of: "=")!
        return String(urlTemplate[tileSizeIndex...])
    }
    
}
