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
    
    
    
    
    func updateLocusInstallers(_ req: Request) -> Future<String> {
        
        let baseInfo = baseHandler.fetchAllFileGenInfo(req)
        
        let result = baseInfo.flatMap(to:String.self) { table in
            
            for line in table {
                self.createInstallerFile(line.groupPrefix, line.clientMapName)
            }
            
            return req.future(table[0].anygisMapName)
        }
        
        return result
    }
    

    
    
    func createInstallerFile(_ prefix: String, _ fileName: String) {
        
        let fullFileName = prefix + "-" + fileName + ".xml"
        let filePatch = templates.pathToInstallers + fullFileName

        diskHandler.createFile(patch: filePatch, content: "hello world!")
    }
    
    
    
    
}
