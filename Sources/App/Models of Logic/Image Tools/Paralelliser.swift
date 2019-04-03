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
    
    
    // Every 2 munutes switch to next account.
    
    public func splitByMinutes() -> String {
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        var sessionNumber = minutes / 2
        
        
        // temp ============================
        let endedAccounts = [13]
        if endedAccounts.contains(sessionNumber) {
            sessionNumber += 1
        }
        // ================================
        
        return String(sessionNumber)
    }
    
    
}
