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



public func shuffledForHeroku<T>(array: [T]) -> [T] {
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


public func makeShuffledOrder(maxNumber: Int) -> [Int:Int] {
    guard maxNumber > 1 else { return [0 : 0] }
    
    var dict = [Int:Int]()
    let shuffled = shuffledForHeroku(array: Array(0..<maxNumber))
    for i in 0..<maxNumber {
        dict[i] = shuffled[i]
    }
    return dict
}


public func getShuffledledIndex(index:Int, order: [Int:Int]) -> Int {
    return order[index] ?? 0
}
