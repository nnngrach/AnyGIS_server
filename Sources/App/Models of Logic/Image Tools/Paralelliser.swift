//
//  Paralelliser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 06/02/2019.
//

import Foundation

// I have 30 free Cloudinary accounts
// with names like anygis0, anygis1, anygis2 ...etc.
// So, number of using account equals sessionID.

class FreeAccountsParalleliser {
    
    
    private let endedCloudinryAccounts : [Int] = [0, 7, 8, 9, 11, 12, 13, 14, 20, 21, 22, 24, 26, 28, 29]
    
    
    // Every 2 munutes switch to next account.
    
    public func splitByMinutes() -> String {
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        var sessionNumber = minutes / 2
        
        
        // TODO: Delete this after 1.05.19 =====================
        if endedCloudinryAccounts.contains(sessionNumber) {
            sessionNumber += 30
        }
        // ==================================================
        
        return String(sessionNumber)
    }
    
    
}
