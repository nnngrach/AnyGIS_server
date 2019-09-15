//
//  CoordinatesMapList.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 14/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import FluentSQLite
import Vapor


final class CoordinateMapList: SQLiteModel {
    
    var id: Int?
    var name: String
    
    var isTesting: Bool
    var hasPrewiew: Bool
    
    var isOverlay: Bool
    
    var previewLat: Double
    var previewLon: Double
    var previewZoom: Int
    var previewUrl: String
    
    var isGlobal: Bool
    var bboxL: Double
    var bboxT: Double
    var bboxR: Double
    var bboxB: Double

    
    
    init(id: Int? = nil, name: String, isTesting: Bool, hasPrewiew: Bool, isOverlay: Bool, previewLat: Double, previewLon: Double, previewZoom: Int, previewUrl: String, isGlobal: Bool, bboxL: Double, bboxT: Double, bboxR: Double, bboxB: Double) {
        self.name = name
        self.isTesting = isTesting
        self.hasPrewiew = hasPrewiew
        self.isOverlay = isOverlay
        self.previewLat = previewLat
        self.previewLon = previewLon
        self.previewZoom = previewZoom
        self.previewUrl = previewUrl
        
        self.isGlobal = isGlobal
        self.bboxL = bboxL
        self.bboxT = bboxT
        self.bboxR = bboxR
        self.bboxB = bboxB
    }
}


extension CoordinateMapList: Migration { }

extension CoordinateMapList: Content { }

extension CoordinateMapList: Parameter { }

