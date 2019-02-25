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
    
    
    func createAll(_ req: Request) {
        
        let clientMapsList = baseHandler.fetchAllFileGenInfo(req)
        let allMapsList = baseHandler.fetchAllMapsList(req)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    guard clientMapsLine.groupName != "Background" else {continue}
                    
                    // Start content agregation
                    var content = self.templates.getLocusMapIntro()
                    
                    content += self.generateLayersContent(clientMapsLine.id!, clientMapsLine.layersIDList, clientMapsTable, allMapsTable)
                    
                    content += self.templates.getLocusMapOutro()
                    
                    // Create file
                    let filename = "__" + clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName + ".xml"
                    
                    let patch = self.templates.localPathToMapsFull + filename
                    
                    self.diskHandler.createFile(patch: patch, content: content)
                }
                
            }
        }
        
    }
    
    
    
    func generateLayersContent(_ currentID: Int, _ layersIdList: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        var content = ""
        
        //TODO: Anygis mode
        
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
            url = "https://anygis.herokuapp.com/\(allMapsLine.name)/{x}/{y}/{z}"
            
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
        
        
        return self.templates.getLocusMapItem(id: clientMapsLine.id!, projection: clientMapsLine.projection, visible: clientMapsLine.visible, background: background, group: clientMapsLine.groupName, name: allMapsLine.description, countries: clientMapsLine.countries, usage: clientMapsLine.usage, url: url, serverParts: serverParts, zoomMin: allMapsLine.zoomMin, zoomMax: allMapsLine.zoomMax, referer: allMapsLine.referer)

    }
    
    
    
}
