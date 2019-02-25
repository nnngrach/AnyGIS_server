//
//  FileGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 21/02/2019.
//

import Vapor

class FileGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    func update(_ req: Request) {
        diskHandler.cleanFolder(patch: templates.pathToInstallers)
        diskHandler.cleanFolder(patch: templates.pathToMarkdownPages)
        
        createLocusSingleMapsInstallers(req)
        createLocusFolderMapsInstallers(req)
        createLocusAllMapsInstallers(isShortSet: true, req)
        createLocusAllMapsInstallers(isShortSet: false, req)
        
        createLocusAllMapsPage(isShortSet: true, req)
        createLocusAllMapsPage(isShortSet: false, req)
    }
    
    
    func createLocusSingleMapsInstallers(_ req: Request) {
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        baseInfo.map { table in
            
            for line in table {
                
                let installerPatch = self.templates.pathToInstallers + "__" + line.groupPrefix + "-" + line.clientMapName + ".xml"

                let content = self.templates.getLocusActionsIntro() + self.templates.getLocusActionsItem(fileName: line.clientMapName, isIcon: false) + self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true) + self.templates.getLocusActionsOutro()
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    func createLocusFolderMapsInstallers(_ req: Request) {
        
        var content = ""
        var previousFolder = ""
        var installerPatch = ""
        var isNotFirstString = false
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        baseInfo.map { table in
            
            for line in table {
       
                if line.groupName != previousFolder {
                    
                    // Last map of the current group.
                    // Finish collecting data and write a file.
                    if isNotFirstString {
                        
                        content += self.templates.getLocusActionsOutro()
                        
                        installerPatch = self.templates.pathToInstallers + "_" + previousFolder + ".xml"
                        
                        self.diskHandler.createFile(patch: installerPatch, content: content)
                    }
                    
                    
                    // Start collecting data for next group
                    isNotFirstString = true
                    previousFolder = line.groupName
                    
                    content = self.templates.getLocusActionsIntro() + self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true) + self.templates.getLocusActionsItem(fileName: line.clientMapName, isIcon: false)
                    
                } else {
                    
                    // Just add current map to group
                    content += self.templates.getLocusActionsItem(fileName: line.clientMapName, isIcon: false)
                }
            }
        }
    }

    
    
    func createLocusAllMapsInstallers(isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        let baseInfo = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let fileName = isShortSet ? "AnyGIS_short_set.xml" : "AnyGIS_full_set.xml"
        
        // Add first part of content
        var content = self.templates.getLocusActionsIntro()
        
        baseInfo.map { table in
            
            // Add all maps and icons
            for line in table {
                
                if line.groupName != previousFolder {
                    previousFolder = line.groupName
                    content += self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true)
                }
                
                content += self.templates.getLocusActionsItem(fileName: line.clientMapName, isIcon: false)
            }
            
            // Add ending part
            content += self.templates.getLocusActionsOutro()
            
            // Create file
            let installerPatch = self.templates.pathToInstallers + fileName
            
            self.diskHandler.createFile(patch: installerPatch, content: content)
        }
    }
    
    
    
    func createLocusAllMapsPage(isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        let fileName = isShortSet ? "Short.md" : "Full.md"
        let clientMapsList = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let allMapsList = baseHandler.fetchAllMapsList(req)
        
        // Add first part of content
        var content = self.templates.getMarkdownHeader() + self.templates.getMarkdownMaplistIntro()
        
        clientMapsList.map { clientMapsTable in
            allMapsList.map { allMapsTable in
                
                // Add all maps and icons
                for clientMapsLine in clientMapsTable {
                    
                    // Add link to Catecory
                    if clientMapsLine.groupName != previousFolder {
                        previousFolder = clientMapsLine.groupName
                        content += self.templates.getMarkdownMaplistCategory(categoryName: clientMapsLine.groupName)
                    }
                    
                    // Add link to single map
                    let allMapsLine = allMapsTable.filter {$0.name == clientMapsLine.anygisMapName}.first!
                    
                    content += self.templates.getMarkDownMaplistItem(name: allMapsLine.description, fileName: clientMapsLine.clientMapName)
                }
                
                // Create file
                let installerPatch = self.templates.pathToMarkdownPages + fileName
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
}
