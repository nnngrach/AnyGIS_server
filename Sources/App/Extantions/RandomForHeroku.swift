//
//  HerokuReplacement.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 01/01/2019.
//

import Foundation


// Heroku server doesn't works with all Swift's standart arc4random functions.
// So this is my simlple realisation of it.

public func randomForHeroku() -> Double {
    let unixTime = Date().timeIntervalSince1970
    let lastDigit = Int(String(String(unixTime).last!))!
    return 0.1 * Double(lastDigit)
}



public func randomNubmerForHeroku(_ maxNumber: Int) -> Int {
    return (Int(Double(maxNumber) * randomForHeroku()))
}



func shuffledForHeroku(array: [String]) -> [String] {
    guard array.count != 0 else {return array}
    let count = array.count
    var result = array
    
    for i in 0 ..< (count - 1) {
        let newIndex = randomNubmerForHeroku(count)
        guard newIndex > i else {continue}
        result.swapAt(i, newIndex)
    }
    
    return result
}
