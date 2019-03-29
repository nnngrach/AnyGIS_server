//
//  OsmandMapGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 21/03/2019.
//


import Vapor
import FluentSQLite


class OsmandMapGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    
    public func createAll(isShortSet: Bool, _ req: Request) {
        
        let allMapsList = baseHandler.fetchAllMapsList(req)
        let clientMapsList = baseHandler.fetchAllFileGenInfo(req)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    guard clientMapsLine.forOsmand else {continue}
                    // Filter for short list
                    if isShortSet && !clientMapsLine.isInStarterSet {continue}
                    
                    let content = self.generateContent(clientMapsLine.id!, clientMapsLine.layersIDList, clientMapsTable, allMapsTable)

                    
                    info.query(on: req).first().map { record in
                        record?.minzoom = content.minzoom
                        record?.maxzoom = content.maxzoom
                        record?.url = content.url
                        record?.tilenumbering = content.tilenumbering
                        record?.timecolumn = content.timecolumn
                        record?.expireminutes = content.expireminutes
                        record?.ellipsoid = content.ellipsoid
                        
                        //record?.update(on: req)
                        
//                        record?.update(on: req).whenComplete {
//                            let filename = clientMapsLine.groupPrefix + "_" + clientMapsLine.clientMapName
//                            self.copyGeneratedMapFile(filename: filename, isShortSet: isShortSet)
//
//                        }
                        
                        
                        
//                        req.withNewConnection(to: DatabaseIdentifier()) { (conn: SQLiteConnection) -> Future<Void> in
//                            
//                            return req.future()
//                        }
                        
                        
                        
                        record?.update(on: req).map { a in
                            let filename = clientMapsLine.groupPrefix + "_" + clientMapsLine.clientMapName
                            self.copyGeneratedMapFile(filename: filename, isShortSet: isShortSet)
                        }
                        
//                        let filename = clientMapsLine.groupPrefix + "_" + clientMapsLine.clientMapName
//                        self.copyGeneratedMapFile(filename: filename, isShortSet: isShortSet)
                        
                    }
                
                    
                }
            }
        }
    }
    
    
    
    
    
    private func generateContent(_ currentID: Int, _ layersIdList: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> info {
        
        let clientMapsLine = clientMapsTable.filter {$0.id == currentID}.first!
        let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
        
        let minzoom = String(allMapsLine.zoomMin - 3)
        let maxzoom = String(allMapsLine.zoomMax - 3)
        let ellipsoid = clientMapsLine.projection == 2 ? 1 : 0
        let url = self.getURL(clientMapsLine, allMapsLine)
        
        return info(minzoom: minzoom,
                           maxzoom: maxzoom,
                           url: url,
                           tilenumbering: "BigPlanet",
                           timecolumn: "0",
                           expireminutes: "0",
                           ellipsoid: ellipsoid,
                           rule: nil)
    }
    
    
    
    private func getURL(_ clientMapsLine: FileGeneratorDB, _ allMapsLine: MapsList) -> String {
        
        var urlTemplate = ""
        let serverParts = allMapsLine.backgroundServerName.replacingOccurrences(of: " ", with: "")
        
        if clientMapsLine.osmandLoadAnygis {
            urlTemplate = self.templates.anygisMapUrlHttp
        } else {
            urlTemplate = allMapsLine.backgroundUrl
        }
        
        urlTemplate = self.prepareURL(urlTemplate, allMapsLine.name)
        
        return urlTemplate
    }
    
    
    
    
    
    private func prepareURL(_ url: String, _ mapName : String) -> String {
        var result = url
        result = result.replacingOccurrences(of: "{mapName}", with: mapName)
        result = result.replacingOccurrences(of: "{x}", with: "{1}")
        result = result.replacingOccurrences(of: "{y}", with: "{2}")
        result = result.replacingOccurrences(of: "{z}", with: "{0}")
        
        return result
    }
    
    
    /*
    private func generateTileLoaderScript(_ allMapsLine: MapsList) -> String {
        
        let origServerParts = Array(allMapsLine.backgroundServerName)
       
        var serverPartsString = ""
        for i in origServerParts {
            serverPartsString.append("\"")
            serverPartsString.append(i)
            serverPartsString.append("\"")
            serverPartsString.append(",")
        }
        serverPartsString = String(serverPartsString.dropLast())
        
        var url = "\"\(allMapsLine.backgroundUrl)\""
        url = url.replacingOccurrences(of: "{x}", with: "\" + x + \"")
        url = url.replacingOccurrences(of: "{y}", with: "\" + y + \"")
        url = url.replacingOccurrences(of: "{z}", with: "\" + z + \"")
        url = url.replacingOccurrences(of: "{s}", with: "\" + eqt(z,x,y) + \"")
        if url.hasSuffix("\"\"") {
            url = String(url.dropLast())
        }
        
        return self.templates.getOsmandUrlScript(serverNames: serverPartsString,
                                                 serverCount: String(origServerParts.count),
                                                 url: url)
    }
    */
    
    
    
    private func copyGeneratedMapFile (filename: String, isShortSet: Bool) {
        
        let sourcePatch = self.templates.localPathToOsmandTemplate
        let destinationFolder = isShortSet ? self.templates.localPathToOsmandMapsShort : self.templates.localPathToOsmandMapsFull
        let destinationPatch = destinationFolder + filename + ".sqlitedb"
    
        self.diskHandler.secureCopyItem(at: sourcePatch, to: destinationPatch)
    }
    
    
}




//struct SQLiteVersion: Codable {
//    let version: String
//}
//
//struct Tetest: SQLTable, Codable {
//    static let sqlTableIdentifierString = "info"
//    let url: String
//}


