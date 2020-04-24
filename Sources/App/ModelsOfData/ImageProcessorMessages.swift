//
//  ImageProcessorMessages.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 05/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Foundation

import Vapor

struct ImageProcessorAttachRowMessage: Content {
    var urlLeft: String
    var urlCentral: String
    var urlRight: String
}


struct ImageProcessorMoveMessage: Content {
    var urlTL: String
    var urlTR: String
    var urlBR: String
    var urlBL: String
    var xOffset: String
    var yOffset: String
}


struct ImageProcessorMoveAndOverlayMessage: Content {
    var urlTL: String
    var urlTR: String
    var urlBR: String
    var urlBL: String
    var xOffset: String
    var yOffset: String
    var overlayUrl: String
}


struct ImageProcessorOverlayMessage: Content {
    var backgroundUrl: String
    var overlayUrl: String
}


struct ImageProcessorOpacityMessage: Content {
    var url: String
    var value: String
}

struct ImageProcessorTextMessage: Content {
    var message: String
    var isWhite: String
}
