//
//  GuruMapsGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 01/03/2019.
//

import Vapor

class GuruMapsGenerator {
    
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
                    guard clientMapsLine.forGuru else {continue}
                    // Filter for short list
                    if isShortSet && !clientMapsLine.isInStarterSet {continue}
                    
                    // Start content agregation
                    var content = self.templates.getGuruMapIntro(mapName: clientMapsLine.shortName, comment: clientMapsLine.comment)
                    
                    content += self.generateLayersContent(clientMapsLine.id!, clientMapsLine.layersIDList, clientMapsTable, allMapsTable)
                    
                    content += self.templates.getGuruMapOutro()
                    
                    // Create file
                    let filename = clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName + ".ms"
                    
                    let patch = isShortSet ? self.templates.localPathToGuruMapsShort : self.templates.localPathToGuruMapsFull
                    
                    let fullPatch = patch + filename
                    
                    self.diskHandler.createFile(patch: fullPatch, content: content)
                }
            }
        }
        
    }
    
    
    
    func generateLayersContent(_ currentID: Int, _ layersIdList: String, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        var content = ""
        
        if layersIdList == "-1" {
            content += self.addLayerBlock(locusId: currentID, clientMapsTable, allMapsTable)
            
        } else {
            let layersId = layersIdList.components(separatedBy: ";")
            
            var loadId = layersId.map {Int($0)!}
            loadId.append(currentID)
            
            for i in 0 ... layersId.count {
                
                content += self.addLayerBlock(locusId: loadId[i], clientMapsTable, allMapsTable)
            }
        }
        
        return content
    }
    
    
    
    
    func addLayerBlock(locusId: Int, _ clientMapsTable: [FileGeneratorDB], _ allMapsTable: [MapsList]) -> String {
        
        let clientMapsLine = clientMapsTable.filter {$0.id == locusId}.first!
        
        let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
        
        // Prepare Url and server parts
        var url = clientMapsLine.gurumapsLoadAnygis ? self.templates.anygisMapUrl : allMapsLine.backgroundUrl
        
        url = prepareUrl(url: url, mapName: allMapsLine.name)
        
        
        var serverParts = ""
        if !clientMapsLine.gurumapsLoadAnygis {
            for i in allMapsLine.backgroundServerName {
                serverParts.append(i)
                serverParts.append(" ")
            }
        }
        
        return self.templates.getGuruMapsItem(url: url, zoomMin: allMapsLine.zoomMin, zoomMax: allMapsLine.zoomMax, serverParts: serverParts)
    }
    
    
    
    func prepareUrl(url: String, mapName: String) -> String {
        var resultUrl = url
        resultUrl = resultUrl.replacingOccurrences(of: "{mapName}", with: mapName)
        resultUrl = resultUrl.replacingOccurrences(of: "{x}", with: "{$x}")
        resultUrl = resultUrl.replacingOccurrences(of: "{y}", with: "{$y}")
        resultUrl = resultUrl.replacingOccurrences(of: "{z}", with: "{$z}")
        resultUrl = resultUrl.replacingOccurrences(of: "{s}", with: "{$serverpart}")
        resultUrl = resultUrl.replacingOccurrences(of: "{invY}", with: "{$invY}")
        resultUrl = resultUrl.replacingOccurrences(of: "&", with: "&amp;")
        return resultUrl
    }
    
}
