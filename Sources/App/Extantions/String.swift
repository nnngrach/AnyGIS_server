//
//  Tes.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 24/02/2019.
//

import Foundation

extension String {
    
    public func makeCorrectPatch() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
    }
    
    public func cleanSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    public func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
}


