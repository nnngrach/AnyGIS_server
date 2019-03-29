//
//  MarkdownPagesGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by Nnngrach on 25/02/2019.
//

import Vapor

class MarkdownPagesGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    public func createMarkdownPage(appName: ClientAppList, isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        
        let firstPart = appName.rawValue.replacingOccurrences(of: " ", with: "_")
        let lastPart = isShortSet ? "_Short.md" : "_Full.md"
        let fullFileName = firstPart + lastPart
        
        let clientMapsList = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let allMapsList = baseHandler.fetchAllMapsList(req)
        
        // Add first part of content
        var content = self.templates.getMarkdownHeader() + self.templates.getMarkdownMaplistIntro(appName: appName)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                // Add all maps and icons
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    if appName == .Locus && !clientMapsLine.forLocus {continue}
                    if appName == .Osmand  && !clientMapsLine.forOsmand {continue}
                    if appName == .Orux  && !clientMapsLine.forOrux {continue}
                    if (appName == .GuruMapsIOS || appName == .GuruMapsAndroid)  && !clientMapsLine.forGuru {continue}
                    
                    // Add link to Catecory
                    if clientMapsLine.groupName != previousFolder {
                        previousFolder = clientMapsLine.groupName
                        content += self.templates.getMarkdownMaplistCategory(appName: appName, categoryName: clientMapsLine.groupName, fileName: clientMapsLine.groupPrefix)
                    }
                    
                    // Add link to single map
                    let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
                    
                    let filename = clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName
                    
                    content += self.templates.getMarkDownMaplistItem(appName: appName, name: clientMapsLine.shortName, fileName: filename)
                }
                
                // Create file
                let installerPatch = self.templates.localPathToMarkdownPages + fullFileName
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    
}
