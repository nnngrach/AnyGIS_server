//
//  WebH.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 04/02/2019.
//

import Foundation
import Vapor

protocol WebHandlerDelegate {
    
    func startSearchingForMap(_ mapName: String, xText:String, _ yText: String, _ zoom: Int, _ req: Request) throws -> Future<Response>
}

