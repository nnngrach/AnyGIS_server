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
    
    
    
    
    
    
    func findTile(_ mapName: String, _ xText: String, _ yText: String, _ zoom: Int, _ mapInfo: MapData) -> ProcessingResult {
        
        // Если пользователь ввел координаты - преобразовать их в номера
        
        do {
            let tileNumbers = try coordinateTransformer.normalizeCoordinates(xText, yText, zoom)
        } catch {
            return ProcessingResult.error(description: "Input values incorrect")
        }
        
        
        
        
        // Запустить требуемый режим по имени
        //временный вариант для проверки работоспособности
        switch mapInfo.mode {
         
            
        case "redirect":
            return ProcessingResult.redirect(url: "https://tiles.nakarte.me/ggc2000/10/615/702")

            
        case "overlay":
//            let filePatch = URL.init(string: "https://tiles.nakarte.me/eurasia25km/8/154/175")!
//            let filePatch = URL.init(string: "https://tiles.nakarte.me/eurasia25km/8/154/175")!
//            let filePatch = URL.init(string: "http://91.237.82.95:8088/pub/genshtab/250m/z11/0/x578/0/y304.jpg")!
            
            let filePatch = URL.init(string: "https://avatars.mds.yandex.net/get-pdb/812271/6b8cb846-29da-49c4-abca-3a210c4280ff/s1200")!
            
            let image = imageProcessor.loadImage(filePatch: filePatch)
            let data = image.getValue().data!
            let extention = image.getValue().text
            return ProcessingResult.image(imageData: data, extention: extention)
 
       
        default:
            return ProcessingResult.error(description: "Unknown mode name")
        }
        
        
        
        //return ProcessingResult.error(description: "Заглушка")
        
    }
    
    
    
    
}
