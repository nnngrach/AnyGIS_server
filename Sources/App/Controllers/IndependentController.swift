//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Foundation

class IndependentController {
    
    let coordinateTransformer = CoordinateTransformer()
    let imageProcessor = ImageProcessor()
    
    
    
    
    
    
    func findTile(_ mapName: String, _ xText: String, _ yText: String, _ zoom: Int) -> ProcessingResult {
        
//        let tileNumbers = try coordinateTransformer.normalizeCoordinates(xText, yText, zoom)
        
        do {
            let tileNumbers = try coordinateTransformer.normalizeCoordinates(xText, yText, zoom)
        } catch {
            return ProcessingResult.error(description: "Input values incorrect")
        }
        
        
        // Запросить строку из базы по имении
        
        // Запустить требуемый режим по имени
        //временный вариант для проверки работоспособности
        switch mapName {
         
        case "overlay":
            return ProcessingResult.redirect(url: "https://tiles.nakarte.me/ggc2000/10/615/702")

            
        case "red":
            return ProcessingResult.redirect(url: "https://tiles.nakarte.me/ggc2000/10/615/702")

            
        case "img":
            let filePatch = URL.init(string: "https://tiles.nakarte.me/eurasia25km/8/154/175")!
            //let filePatch = URL.init(string: "http://91.237.82.95:8088/pub/genshtab/250m/z11/0/x578/0/y304.jpg")!
            let image = imageProcessor.loadImage(filePatch: filePatch)
            let data = image.getValue().data!
            let extention = image.getValue().text
            return ProcessingResult.image(imageData: data, extention: extention)
 
       
        default:
            return ProcessingResult.error(description: "Unknown Map name")
        }
        
        
        
        return ProcessingResult.error(description: "Заглушка")
        
    }
    
    
    
    
}
