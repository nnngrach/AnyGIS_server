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
    
    private let allCLoudinaryAccountsCount = 100
    
    private let endedCloudinryAccounts : [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
                                                  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                                                  20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
                                                  30]
    
    
    // Every 30 seconds switch to next account.
    
    public func splitByMinutes() -> String {
        
        /*
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        // for 0 to 119
        var sessionNumber = (minutes * 2) + (seconds / 30)
        */
        
        let hundreedOfMinutes = Int(Date().timeIntervalSince1970) % 10000 / 100
        var sessionNumber = hundreedOfMinutes
        
        
        // TODO: Delete this after 1.05.19 =====================
        if endedCloudinryAccounts.contains(sessionNumber) {
            /*
            sessionNumber = findFirstWorkingAccount(currentAccount: sessionNumber)
            
            if sessionNumber >= allCLoudinaryAccountsCount {
                sessionNumber = findFirstWorkingAccount(currentAccount: 0)
            }
            */
            
            sessionNumber = sessionNumber / 69 + 32
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
