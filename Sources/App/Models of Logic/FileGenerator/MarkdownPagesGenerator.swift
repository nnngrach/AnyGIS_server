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
    
    
    func createMarkdownPage(forLocus:Bool, isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        
        let firstPart = forLocus ? "Locus" : "Guru"
        let secondPart = isShortSet ? "Short.md" : "Full.md"
        let fullFileName = firstPart + secondPart
        
        let clientMapsList = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let allMapsList = baseHandler.fetchAllMapsList(req)
        
        // Add first part of content
        var content = self.templates.getMarkdownHeader() + self.templates.getMarkdownMaplistIntro(forLocus: forLocus)
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                // Add all maps and icons
                for clientMapsLine in clientMapsTable {
                    
                    // Filter off service layers
                    if forLocus && !clientMapsLine.forLocus {continue}
                    if !forLocus && !clientMapsLine.forGuru {continue}
                    
                    // Add link to Catecory
                    if clientMapsLine.groupName != previousFolder {
                        previousFolder = clientMapsLine.groupName
                        content += self.templates.getMarkdownMaplistCategory(forLocus: forLocus, categoryName: clientMapsLine.groupName, fileName: clientMapsLine.groupPrefix)
                    }
                    
                    // Add link to single map
                    let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
                    
                    let filename = clientMapsLine.groupPrefix + "-" + clientMapsLine.clientMapName
                    
                    content += self.templates.getMarkDownMaplistItem(forLocus: forLocus, name: allMapsLine.description, fileName: filename)
                }
                
                // Create file
                let installerPatch = self.templates.localPathToMarkdownPages + fullFileName
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    
}
