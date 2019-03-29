//
//  OruxMapsGeneratr.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 20/03/2019.
//

import Vapor

class OruxMapsGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    public func createAll(isShortSet: Bool, _ req: Request) {
        
        let allMapsList = baseHandler.fetchAllMapsList(req)
        let clientMapsList = baseHandler.fetchAllFileGenInfo(req)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                // Start content agregation
                var content = self.templates.getOruxMapIntro()
                
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    guard clientMapsLine.forOrux else {continue}
                    // Filter for short list
                    if isShortSet && !clientMapsLine.isInStarterSet {continue}
                    
                    content += self.generateLayersContent(clientMapsLine.id!, clientMapsLine.layersIDList, clientMapsTable, allMapsTable)
                }
                
                
                content += self.templates.getOutroMapOutro()
                
                // Create file
                let patch = isShortSet ? self.templates.localPathToOruxMapsShortInServer : self.templates.localPathToOruxMapsFullInServer
                
                let fullPatch = patch + "onlinemapsources.xml"
                
                self.diskHandler.createFile(patch: fullPatch, content: content)
            
            }
        }
    }
    
    
    
    
    private func generateLayersContent(_ currentID: Int, _ layersIdList: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        //var content = ""
        
        let clientMapsLine = clientMapsTable.filter {$0.id == currentID}.first!
        
        let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
        
        
        // Prepare Url and server parts
        
        var url = clientMapsLine.oruxLoadAnygis ? self.templates.anygisMapUrl : allMapsLine.backgroundUrl
        
        url = url.replacingOccurrences(of: "{x}", with: "{$x}")
        url = url.replacingOccurrences(of: "{y}", with: "{$y}")
        url = url.replacingOccurrences(of: "{z}", with: "{$z}")
        url = url.replacingOccurrences(of: "{s}", with: "{$s}")
        url = url.replacingOccurrences(of: "{invY}", with: "{$y}")
        url = url.replacingOccurrences(of: "{$quad}", with: "{$q}")
        url = url.replacingOccurrences(of: "{mapName}", with: allMapsLine.name)
        
        var serverParts = ""
        let origServerParts = allMapsLine.backgroundServerName
        for i in origServerParts {
            serverParts.append(i)
            serverParts.append(",")
        }
        serverParts = String(serverParts.dropLast())
        
        
        
        var yInvertingScript = ""
        var currentProjection = ""
        
        switch clientMapsLine.projection {
        case 0, 5:
            currentProjection = "MERCATORESFERICA"
        case 1:
            currentProjection = "MERCATORESFERICA"
            yInvertingScript = "0"
        case 2:
            currentProjection = "MERCATORELIPSOIDAL"
        default:
            fatalError("Wrong proection in ORUX generateLayersContent()")
        }
        
        
        let cacheable = clientMapsLine.cacheStoringHours == 0 ? 0 : 1
        
        
        return self.templates.getOruxMapsItem(id: clientMapsLine.id!, projectionName: currentProjection, name: clientMapsLine.shortName, group: clientMapsLine.oruxGroupPrefix, url: url, serverParts: serverParts, zoomMin: allMapsLine.zoomMin, zoomMax: allMapsLine.zoomMax, cacheable: cacheable, yInvertingScript: yInvertingScript)
    }
    
    
    
}
