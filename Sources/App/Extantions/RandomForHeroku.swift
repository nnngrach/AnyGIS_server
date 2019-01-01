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



public func selectOneForHeroku(_ count: Int) -> Int {
    return (Int(Double(count) * randomForHeroku()))
}



func herokuShuffled(array: [String]) -> [String] {
    guard array.count != 0 else {return array}
    let count = array.count
    var result = array
    
    for i in 0 ..< (count - 1) {
        let newIndex = selectOneForHeroku(count)
        print(newIndex)
        guard newIndex == 1 else {continue}
        result.swapAt(i, newIndex)
    }
    
    return result
}
