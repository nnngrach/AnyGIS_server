//
//  Tes.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Foundation

extension String {
    
    public func makeCorrectPatch() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
    }
    
    public func cleanSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
}


