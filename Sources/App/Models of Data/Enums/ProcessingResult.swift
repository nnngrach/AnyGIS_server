//
//  Enums.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation

//enum Extention {
//    case jpg, png
//}

enum ProcessingResult {
    case redirect(url: String)
    case image(imageData: Data, extention: String)
    case error(description: String)
    
    func getValue() -> (text: String, data: Data?) {
        switch self {
        case .redirect(let url):
            return (url, nil)
        case .image(let imageData, let extention):
            return (extention, imageData)
        case .error(let description):
            return (description, nil)
        }
    }
    
}


