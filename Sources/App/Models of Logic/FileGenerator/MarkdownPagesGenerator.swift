//
//  MarkdownPagesGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 25/02/2019.
//

import Vapor

class MarkdownPagesGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    func createLocusPage(isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        let fileName = isShortSet ? "LocusShort.md" : "LocusFull.md"
        let clientMapsList = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let allMapsList = baseHandler.fetchAllMapsList(req)
        
        // Add first part of content
        var content = self.templates.getMarkdownHeader() + self.templates.getMarkdownMaplistIntro()
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                // Add all maps and icons
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    guard clientMapsLine.groupName != "Background" else {continue}
                    
                    // Add link to Catecory
                    if clientMapsLine.groupName != previousFolder {
                        previousFolder = clientMapsLine.groupName
                        content += self.templates.getMarkdownMaplistCategory(categoryName: clientMapsLine.groupName)
                    }
                    
                    // Add link to single map
                    let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
                    
                    let filename = clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName
                    
                    content += self.templates.getMarkDownMaplistItem(name: allMapsLine.description, fileName: filename)
                }
                
                // Create file
                let installerPatch = self.templates.localPathToMarkdownPages + fileName
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    
}
