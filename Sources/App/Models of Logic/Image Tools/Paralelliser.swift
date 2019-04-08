//
//  Paralelliser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 06/02/2019.
//

import Foundation

// I have 60 free Cloudinary accounts
// with names like anygis0, anygis1, anygis2 ...etc.
// So, number of using account equals sessionID.

class FreeAccountsParalleliser {
    
    private let allCLoudinaryAccountsCount = 60
    
    private let endedCloudinryAccounts : [Int] = [0, 1, 2, 7, 8, 9,
                                                  11, 12, 13, 14, 15, 19,
                                                  20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
    
    
    // Every 1 munutes switch to next account.
    
    public func splitByMinutes() -> String {
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        var sessionNumber = minutes
        
        
        // TODO: Delete this after 1.05.19 =====================
        if endedCloudinryAccounts.contains(sessionNumber) {
            sessionNumber = findFirstWorkingAccount(currentAccount: sessionNumber)
            
            if sessionNumber >= allCLoudinaryAccountsCount {
                sessionNumber = findFirstWorkingAccount(currentAccount: 0)
            }
        }
        // ==================================================
        
        return String(sessionNumber)
    }
    
    
    
    
    
    private func findFirstWorkingAccount(currentAccount: Int) -> Int {
        
        var nextAccount = currentAccount
        
        while endedCloudinryAccounts.contains(nextAccount) {
            nextAccount += 1
        }
        
        return nextAccount
    }
    
    
}
