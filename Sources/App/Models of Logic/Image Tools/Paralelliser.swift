//
//  Paralelliser.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 06/02/2019.
//

import Foundation

// I have 10 free Cloudinary accounts
// with names like anygis0, anygis1, anygis2 ...etc.
// So, number of using account equals sessionID.

class FreeAccountsParalleliser {
    
    let cloudinaryServersCount = 10
    
    func splitByRandom() -> String {
        let randomValue = randomNubmerForHeroku(cloudinaryServersCount)
        return String(randomValue)
    }
    
    
    func splitByTime() -> String {
        let time = Int(Date.timeIntervalSinceReferenceDate)
        let tenSeconds = (time % 100) / 10
        return String(tenSeconds)
    }
    
    
    func splitBy(tileNumber: Int) -> String {
        let number = (tileNumber % 100) / 10
        return String(number)
    }
    
}
