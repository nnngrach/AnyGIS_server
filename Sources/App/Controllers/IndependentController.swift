//
//  IndependentController.swift
//  AnyGIS_ServerPackageDescription
//
//  Created by nnngrach on 26/11/2018.
//

import Vapor
import Foundation

class IndependentController {
    
    let baseHandler = BaseHandler()
    let coordinateTransformer = CoordinateTransformer()
    let imageProcessor = ImageProcessor()
    
    
    
    
    
    
    func findTile(_ mapName: String, _ xText: String, _ yText: String, _ zoom: Int, _ mapObject: MapData) -> ProcessingResult {
        
        // Если пользователь ввел координаты вместо номеров тайлов - надо преобразовать
        guard let tileNumbers = try? coordinateTransformer.normalizeCoordinates(xText, yText, zoom)
            else {return ProcessingResult.error(description: "Input values incorrect")}
        
//        guard let mapInfo = try? baseHandler.getFirstWith(mapName: mapName, request)
//            else {return ProcessingResult.error(description: "Fething map from database error")}
        
        let mapInfo = "overlay"
        
        
        // Запустить требуемый режим по имени
        //временный вариант для проверки работоспособности
        switch mapInfo {
//        switch mapInfo.mode {
         
            
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
    }
    
    
    
    
    
    
    
    
    
    
    
    // ==================================
 /*
    struct FileContent: Content {
        var file: File
    }
    
    func uploadUser(_ req: Request) throws -> Future<HTTPStatus> {
        print("uploadUserImage")
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let name = UUID().uuidString + ".jpg"
        let imageFolder = "profile/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        return try req.content.decode(FileContent.self).map { payload in
            do {
                try payload.file.data.write(to: saveURL)
                print("payload: \(payload)")
                return .ok
            } catch {
                print("error: \(error)")
                throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
            }
        }
    }
    
    
    func uploadUser2(_ req: Request) throws -> Future<HTTPStatus> {
        print("uploadUserImage")
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        //let name = UUID().uuidString + ".jpg"
        let name = "123.png"
        let imageFolder = "Public/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        return try req.content.decode(FileContent.self).map { payload in
            do {
                try payload.file.data.write(to: saveURL)
                print("payload: \(payload)")
                return .ok
            } catch {
                print("error: \(error)")
                throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
            }
        }
    }
    
    
    func upload(_ req: Request) throws -> Future<String> {
        return try req.content.decode(File.self).map(to: String.self) { video in
            try video.data.write(to: URL(fileURLWithPath: "/Users/eivindml/Desktop/video.mp4"))
            return "Video uploaded"
        }
    }
    
    
    func test2(_ req: Request) throws {
        let dirConfig = DirectoryConfig.detect()
        let workingDir = dirConfig.workDir
        let pathToFile = workingDir + "file.txt"
        
        
        let client = try req.make(Client.self)
        let res = try req.client().get("http://vapor.codes")
        print(res) // Future<Response>
        
    }
 */
}
