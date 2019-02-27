//
//  DiskHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Foundation
//import ZipArchive

class DiskHandler {
    
    func createFile(patch: String, content: String) {
        
        let url = URL(string: patch.cleanSpaces())!
        
        do {
            try content.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
    }
    
    
    func cleanFolder(patch: String) {
        
        let folderUrl = URL(string: patch)!
        
        do {
            let fileURLs = try FileManager
                .default
                .contentsOfDirectory(at: folderUrl,
                                     includingPropertiesForKeys: nil,
                                     options: [.skipsHiddenFiles,
                                               .skipsSubdirectoryDescendants])
            
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            
        } catch {
            print(error)
        }
    }
    
}
