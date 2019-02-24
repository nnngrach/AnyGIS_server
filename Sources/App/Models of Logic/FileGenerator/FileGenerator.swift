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
                        
                        print(installerPatch)
                        
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

    
    
    func createLocusFilesetMapsInstallers(_ req: Request) {
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        baseInfo.map { table in
            
            for line in table {
                
                let installerPatch = self.templates.pathToInstallers + "__" + line.groupPrefix + "-" + line.clientMapName + ".xml"
                
                let content = self.templates.getLocusActionsIntro() + self.templates.getLocusActionsItem(fileName: line.clientMapName, isIcon: false) + self.templates.getLocusActionsItem(fileName: line.groupName, isIcon: true) + self.templates.getLocusActionsOutro()
                
                self.diskHandler.createFile(patch: installerPatch, content: content)
            }
        }
    }
    
    
    
    
    
    //TODO: Generate Fullset installers
    
    //TODO: Generate beginner set installers
    
    //TODO: Generate MarkDownPage installers
    
}
