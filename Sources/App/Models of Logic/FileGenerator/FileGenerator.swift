//
//  FileGenerator.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 21/02/2019.
//

import Vapor

class FileGenerator {
    
    let baseHandler = SQLHandler()
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
        
//        let str = "Hello, World!"
        

        
        
        
        let fullFileName = prefix + "-" + fileName + ".xml"

        let patch = URL(string: templates.pathToInstallers + fullFileName)!
    
        
        
        let content = """
<?xml version="1.0" encoding="utf-8"?>
<locusActions>

    <download>
        <source>
            <![CDATA[https://raw.githubusercontent.com/nnngrach/map-sources/master/Locus_online_maps/Full_set/\(fullFileName)]]>
        </source>
        <dest>
            <![CDATA[/mapsOnline/custom/\(fullFileName)]]>
        </dest>
    </download>

</locusActions>
"""
        
    
        do {
            try content.write(to: patch, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
    }
    
    
    
    
    func cleanFolder(patch: String) {
        
    }
    
}
