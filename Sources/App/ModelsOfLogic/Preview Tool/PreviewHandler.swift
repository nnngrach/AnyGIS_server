//
//  PreviewHandler.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by HR_book on 14/09/2019.
//  Copyright © 2019 Nnngrach. All rights reserved.
//

import Vapor
import Foundation

class PreviewHandler {
    
    private let baseHandler = SQLHandler()
    

    public func generateLinkForOneTilePreview(mapName: String, req: Request) throws -> Future<String> {
    
        let errorTileUrl = "https://anygis.ru/Web/Img/tiles/tile_error.png"
        
        // Load records from db
        let mapListData = try baseHandler.getBy(mapName: mapName, req)
        let coordinatesData = try baseHandler.getCoordinatesDataBy(name: mapName, req)
        
        // synchronize
            return coordinatesData.flatMap(to: String.self) { previewRecord in
                guard previewRecord.hasPrewiew else {return req.future(errorTileUrl)}
                
                
                let previewLink = "https://anygis.ru/api/v1/\(mapName)/\(previewRecord.previewLat)/\(previewRecord.previewLon)/\(previewRecord.previewZoom)"
                
                return req.future(previewLink)
            }
    }
        
    
    
    
    public func generateLinkFor(mapName: String, req: Request) throws -> Future<String> {
        
        // Load records from db
        let mapListData = try baseHandler.getBy(mapName: mapName, req)
        let coordinatesData = try baseHandler.getCoordinatesDataBy(name: mapName, req)
        
        // synchronize
        return coordinatesData.flatMap(to: String.self) { previewRecord in
            
            // if record already have url for previw
            // (specialUrl field not empty), then just return it
            var specialUrl = previewRecord.previewUrl
            specialUrl = specialUrl.replacingOccurrences(of: " ", with: "")
           
            if specialUrl != "" {
                return req.future(specialUrl)
            }
            
            // else generate url with current custom map parameters
            return mapListData.map(to: String.self) { mapListRecord in
                
                let nakarteMaxZoom = 18
                
                let maxZoom = (mapListRecord.zoomMax <= nakarteMaxZoom) ? mapListRecord.zoomMax : nakarteMaxZoom
                
                let mapParametersInJson = self.getNakarteJson(dbMapName: mapName,
                                          descriptionName: mapListRecord.description,
                                          maxZoom: maxZoom,
                                          isOverlay: previewRecord.isOverlay)
                
                
                let mapParametersInBase64 = self.convertToBase64(mapParametersInJson)
                
                let nakartePrefix = "https://nakarte.me/#m="
                
                let overlayPrefix = previewRecord.isOverlay ? "O/" : ""
                
                let previewUrl = nakartePrefix + String(previewRecord.previewZoom) + "/" + String(previewRecord.previewLat) + "/" + String(previewRecord.previewLon) + "&l=" + overlayPrefix + "-cs" + mapParametersInBase64!
                
                print(mapParametersInJson)
                print(previewUrl)
    
                return previewUrl
            }
        }
    }
    
    
    
    
    private func getNakarteJson(dbMapName: String, descriptionName: String, maxZoom: Int, isOverlay: Bool) -> String {
        
        let processedMapName = replaceIncorrectSymbols(descriptionName)
    
        let anygisMapUrl = SERVER_HOST + dbMapName + "/{x}/{y}/{z}"
        
        print(descriptionName)
        
        return """
        {
        "name": "\(processedMapName)",
        "url": "\(anygisMapUrl)",
        "tms": false,
        "scaleDependent": false,
        "maxZoom": \(maxZoom),
        "isOverlay": \(isOverlay),
        "isTop": true
        }
        """
    }
    
    
    
    func convertToBase64(_ text: String) -> String? {
        
        guard let data = text.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    
    
    private func replaceIncorrectSymbols(_ text: String) -> String {
        
        var processedText = text
        
        for i in 0 ..< letters.count {
            processedText = processedText.replacingOccurrences(of: letters[i],
                                                               with: codes[i])
        }
        
        return processedText
    }
    
    
    
    private let letters = [
                   "\\","\"","а", "б", "в",
                   "г", "д", "е", "ё", "ж", "з", "и",
                   "й", "к", "л", "м", "н", "о", "п",
                   "р", "с", "т", "у", "ф", "х", "ц",
                   "ч", "ш", "щ", "ъ", "ы", "ь", "э",
                   "ю", "я", "А", "Б", "В", "Г", "Д",
                   "Е", "Ё", "Ж", "З", "И", "Й", "К",
                   "Л", "М", "Н", "О", "П", "Р", "С",
                   "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш",
                   "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я",
                   ]
    
    private let codes = [
         "\\\\",    "\\\"",    "\\u0430", "\\u0431", "\\u0432",
         "\\u0433", "\\u0434", "\\u0435", "\\u0451", "\\u0436", "\\u0437", "\\u0438",
         "\\u0439", "\\u043A", "\\u043B", "\\u043C", "\\u043D", "\\u043E", "\\u043F",
         "\\u0440", "\\u0441", "\\u0442", "\\u0443", "\\u0444", "\\u0445", "\\u0446",
         "\\u0447", "\\u0448", "\\u0449", "\\u044A", "\\u044B", "\\u044C", "\\u044D",
         "\\u044E", "\\u044F", "\\u0410", "\\u0411", "\\u0412", "\\u0413", "\\u0414",
         "\\u0415", "\\u0401", "\\u0416", "\\u0417", "\\u0418", "\\u0419", "\\u041A",
         "\\u041B", "\\u041C", "\\u041D", "\\u041E", "\\u041F", "\\u0420", "\\u0421",
         "\\u0422", "\\u0423", "\\u0424", "\\u0425", "\\u0426", "\\u0427", "\\u0428",
         "\\u0429", "\\u042A", "\\u042B", "\\u042C", "\\u042D", "\\u042E", "\\u042F",
         ]

}
