//
//  Paralelliser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 06/02/2019.
//

import Vapor

// I have 100 free Cloudinary accounts
// with names like anygis0, anygis1, anygis2 ...etc.
// So, number of using account equals sessionID.

class FreeAccountsParalleliser {
    
    let sqlHandler = SQLHandler()
    let mapboxAccountCount = 30
    let cloudinaryAccountCount = 100
    
    
    public func getMapboxSessionId() -> String {
        
        let randomNumber = getRandomByUnixTimeMinutes() / mapboxAccountCount
        
        return String(randomNumber)
    }
    
    
    
    public func getCloudinarySessionId(_ req: Request) throws -> Future<String>{
        
        
        let randomNumber = getRandomByUnixTimeMinutes()
        
        let workingAccountsString = try getWorkingAccountsList(req)
        
        let firstWorkingAccount = workingAccountsString.map { text -> String in
            
            var workingAccounts = text.components(separatedBy: ";")
        
            let firstWorkingAccountNumber = try self.findFirstWorkingAccount(randomNumber, workingAccounts)
            
            return String(firstWorkingAccountNumber)
        }
        
        return firstWorkingAccount
    }
    
    
    
    private func getRandomByUnixTimeMinutes() -> Int {
        
        let hundreedOfMinutes = Int(Date().timeIntervalSince1970) % 10000 / 100
        
        return hundreedOfMinutes
    }
    
    
    
    private func getWorkingAccountsList(_ req: Request) throws -> Future<String> {
        
        return try sqlHandler.getServiceDataBy(serviceName: "CloudinaryWorkedAccountsList", req)
            .map { record -> String in
                
                return record[0].apiSecret
        }
    }
    
    

    
    private func findFirstWorkingAccount(_ randomSessionNumber: Int, _ workingAccountsList: [String]) throws -> Int {
        
        for i in randomSessionNumber ..< cloudinaryAccountCount {
            
            if workingAccountsList.contains(String(randomSessionNumber)) {
                return i
            }
        }
        
        for i in 0 ..< randomSessionNumber {
            
            if workingAccountsList.contains(String(randomSessionNumber)) {
                return i
            }
        }
        
        throw GlobalErrors.internalServerError
    }
    
    
    
    
    /*
    // Switch to next Strava account every 25000 sec
    // (This is about every 7 hours)
    public func getStravaSessionId() -> String {
        
        //let sessionNumber = Int((Double(Int(Date().timeIntervalSince1970) % 100000) / 100000) * 4.0)
        
        let sessionNumber = randomNubmerForHeroku(4)

        return "Strava" + String(sessionNumber)
    }
    */
    
}
