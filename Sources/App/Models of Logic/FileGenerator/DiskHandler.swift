//
//  DiskHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 24/02/2019.
//

import Foundation

class DiskHandler {
    
    public func createFile(patch: String, content: String) {
        
        let url = URL(string: patch.cleanSpaces())!
        
        do {
            try content.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
    }
    
    
    public func cleanFolder(patch: String) {
        
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
    
    
    
    public func cleanXmlFromFolder(patch: String) {
        
        let folderUrl = URL(string: patch)!
        
        do {
            let fileURLs = try FileManager
                .default
                .contentsOfDirectory(at: folderUrl,
                                     includingPropertiesForKeys: nil,
                                     options: [.skipsHiddenFiles,
                                               .skipsSubdirectoryDescendants])
            
            for fileURL in fileURLs {
                if fileURL.absoluteString.hasSuffix(".xml") {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    
    
    
    public func secureCopyItem(at source: String, to destination: String) -> Bool {
        
        let srcURL = URL(string: source)!
        let dstURL = URL(string: destination)!
        
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
    
    
}
