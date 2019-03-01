//
//  LocusMapsGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 25/02/2019.
//

import Vapor

class LocusMapsGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    func createAll(isShortSet: Bool, _ req: Request) {
        
        let allMapsList = baseHandler.fetchAllMapsList(req)
        let clientMapsList = baseHandler.fetchAllFileGenInfo(req)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    guard clientMapsLine.forLocus else {continue}
                    // Filter for short list
                    if isShortSet && !clientMapsLine.isInStarterSet {continue}
 
                    
                    // Start content agregation
                    var content = self.templates.getLocusMapIntro(comment: clientMapsLine.comment)
                    
                    content += self.generateLayersContent(clientMapsLine.id!, clientMapsLine.layersIDList, clientMapsTable, allMapsTable)
                    
                    content += self.templates.getLocusMapOutro()
                    
                    // Create file
                    let filename = clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName + ".xml"
                    
                    let patch = isShortSet ? self.templates.localPathToLocusMapsShort : self.templates.localPathToLocusMapsFull
                    
                    let fullPatch = patch + filename
                    
                    self.diskHandler.createFile(patch: fullPatch, content: content)
                }
            }
        }
        
    }
    
    
    
    func generateLayersContent(_ currentID: Int, _ layersIdList: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        var content = ""
        
        if layersIdList == "-1" {
            
            content += self.addLayerBlock(locusId: currentID, background: "-1", clientMapsTable, allMapsTable)
            
            
        } else {
            
            let layersId = layersIdList.components(separatedBy: ";")
            
            var loadId = layersId.map {Int($0)!}
            loadId.append(currentID)
            
            var backroundId = ["-1"]
            backroundId += layersId
            
            
            for i in 0 ... layersId.count {
                
                content += self.addLayerBlock(locusId: loadId[i], background: backroundId[i], clientMapsTable, allMapsTable)
            }

        }
        
        return content
    }
    
    
    
    
    
    func addLayerBlock(locusId: Int, background: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        let clientMapsLine = clientMapsTable.filter {$0.id == locusId}.first!
        
        let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
        
        
        // Prepare Url and server parts
        var url = ""
        var serverParts = ""
        
        if clientMapsLine.locusLoadAnygis {
            url = self.templates.anygisMapUrl
            url = url.replacingOccurrences(of: "{mapName}", with: allMapsLine.name)
            
        } else {
            url = allMapsLine.backgroundUrl
            url = url.replacingOccurrences(of: "{invY}", with: "{y}")
            
            let origServerParts = allMapsLine.backgroundServerName
            for i in origServerParts {
                serverParts.append(i)
                serverParts.append(";")
            }
            serverParts = String(serverParts.dropLast())
        }
        
        
        return self.templates.getLocusMapItem(id: clientMapsLine.id!, projection: clientMapsLine.projection, visible: clientMapsLine.visible, background: background, group: clientMapsLine.groupName, name: clientMapsLine.shortName, countries: clientMapsLine.countries, usage: clientMapsLine.usage, url: url, serverParts: serverParts, zoomMin: allMapsLine.zoomMin, zoomMax: allMapsLine.zoomMax, referer: allMapsLine.referer)

    }
    

    
    
}
