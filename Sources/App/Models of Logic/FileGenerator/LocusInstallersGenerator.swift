//
//  GenerateoOfLocusInstallers.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 25/02/2019.
//

import Vapor

class LocusInstallersGenerator {
    
    let baseHandler = SQLHandler()
    let diskHandler = DiskHandler()
    let templates = TextTemplates()
    
    
    
    public func createSingleMapsLoader(_ req: Request) {
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        baseInfo.map { table in
            
            for line in table {
                
                // Filter off service layers
                guard line.forLocus else {continue}
                
                let mapFileName = line.groupPrefix + "-" + line.clientMapName
                let installerPatch = self.templates.localPathToInstallers + "__" + mapFileName + ".xml"
                
                let content = self.templates.getLocusActionsIntro() + self.templates.getLocusActionsItem(fileName: mapFileName, isIcon: false) + self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true) + self.templates.getLocusActionsOutro()
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    
    
    public func createFolderLoader(_ req: Request) {
        
        var content = ""
        var previousFolder = ""
        var installerPatch = ""
        var isNotFirstString = false
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        baseInfo.map { table in
            
            for line in table {
                
                // Filter off service layers
                guard line.forLocus else {continue}
                
                let mapFileName = line.groupPrefix + "-" + line.clientMapName
                
                if line.groupPrefix != previousFolder {
                    
                    // Last map of the current group.
                    // Finish collecting data and write a file.
                    if isNotFirstString {
                        self.finishAndWriteLocusFolderInstaller(folderName: previousFolder, content: content)
                    }
                    
                    // Start collecting data for next group
                    isNotFirstString = true
                    previousFolder = line.groupPrefix
                    
                    content = self.templates.getLocusActionsIntro() + self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true) + self.templates.getLocusActionsItem(fileName: mapFileName, isIcon: false)
                    
                } else {
                    
                    // Just add current map to group
                    content += self.templates.getLocusActionsItem(fileName: mapFileName, isIcon: false)
                }
                
                
                // For last iteration: write collected data to last file
                self.finishAndWriteLocusFolderInstaller(folderName: previousFolder, content: content)
            }
        }
    }
    
    
    
    private func finishAndWriteLocusFolderInstaller(folderName: String, content: String) {
        
        let resultContent = content + self.templates.getLocusActionsOutro()
        
        let installerPatch = self.templates.localPathToInstallers + "_" + folderName + ".xml"
        
        self.diskHandler.createFile(patch: installerPatch, content: content)
    }
    
    
    
    
    
    public func createAllMapsLoader(isShortSet: Bool, _ req: Request) {
        
        var previousFolder = ""
        let baseInfo = isShortSet ? baseHandler.fetchShortSetFileGenInfo(req) : baseHandler.fetchAllFileGenInfo(req)
        let fileName = isShortSet ? "AnyGIS_short_set.xml" : "AnyGIS_full_set.xml"
        
        // Add first part of content
        var content = self.templates.getLocusActionsIntro()
        
        baseInfo.map { table in
            
            // Add all maps and icons
            for line in table {
                
                // Filter off service layers
                guard line.forLocus else {continue}
                
                if line.groupName != previousFolder {
                    previousFolder = line.groupName
                    content += self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true)
                }
                
                let mapFileName = line.groupPrefix + "-" + line.clientMapName
                content += self.templates.getLocusActionsItem(fileName: mapFileName, isIcon: false)
            }
            
            // Add ending part
            content += self.templates.getLocusActionsOutro()
            
            // Create file
            let installerPatch = self.templates.localPathToInstallers + fileName
            
            self.diskHandler.createFile(patch: installerPatch, content: content)
        }
    }
    
}
