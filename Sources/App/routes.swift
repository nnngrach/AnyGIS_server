import Foundation
import Vapor
import FluentSQLite
//import UIKit
//import Storage

/// Register your application's routes here.
public func routes(_ router: Router) throws {

/*
    
    let baseHandler = BaseHandler()
    let controller = IndependentController()
    
    //    вернуть таблицу с названием всех карт и их описанием
    //router.get("list", use: baseHandler.list)
    

    
/*
    router.get("list") { req -> Future<String> in
        /// Create a new void promise
        let promise = req.eventLoop.newPromise(Void.self)
        
        /// Dispatch some work to happen on a background thread
        
        var result = [MapData]()
        
        DispatchQueue.main.async {
            sleep(5)
//            guard let a = try? baseHandler.list(req) else {return}
//            result = a
            promise.succeed()
            }
        

        return promise.futureResult.transform(to: "Hello, world!")
    }
 */
    
    
  /*
    router.get("hello") { req -> Future<String> in
        /// Create a new void promise
        let promise = req.eventLoop.newPromise(Void.self)
        
        /// Dispatch some work to happen on a background thread
        DispatchQueue.main.async() {
            /// Puts the background thread to sleep
            /// This will not affect any of the event loops
            sleep(5)
            
            /// When the "blocking work" has completed,
            /// complete the promise and its associated future.
            promise.succeed()
        }
        
        /// Wait for the future to be completed,
        /// then transform the result to a simple String
        return promise.futureResult.transform(to: "Hello, world!")
    }
    */
    
    
    
    
//    router.get(String.parameter, String.parameter, String.parameter,Int.parameter, use: vaporController.startFindingTile)
    
    
//    Вернуть изображение по ссылке с указанным значение прозрачности
//    router.get("opacity", Double.parameter, String.parameter, use: controller.splitter)

    
    
    // TODO: Возвращать не просто текст из переменно
    // (тем более, глобальной и публичной)
    // а HTML страничку
    
    router.get { req in
        //return "Welcome to AnyGIS!"
        return instructionText
    }
    
    
    
    
    
    
    // Запуск главного алгоритма
    /*
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Response in
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        
        let outputData = controller.findTile(mapName, xText, yText, zoom, request)
        
        switch outputData {
            
        case .redirect(let url):
            return request.redirect(to: url)
            
            
        case .image(let imageData, let extention):
            // It works with png and jpg???
            return request.makeResponse(imageData, as: MediaType.png)
            
            /*
             if (extention == "png") {
             return req.makeResponse(imageData, as: MediaType.png)
             } else if (extention == "jpg") || (extention == "jpeg") {
             return req.makeResponse(imageData, as: MediaType.jpeg)
             } else {
             return req.makeResponse(imageData, as: MediaType.png)
             //throw "Unsupportable loaded file extention"
             }
             */
            
        case .error(let desctiption):
            return request.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: desctiption), body: ""))
        }
    }
    */

    
    
    
    
    
    // получаемОбъектКарты.flatMap { объектКарты in
    //    switch объектКарты.mode {
    //    case overlay:
    //        получаемСписокИзВторойБазы.flatmap { список in
    //            основнойАлгоритм(координаты, объектКарты, список1)
    //        }
    //    case mapSet:
    //        получаемСписокИзВторойБазы.flatmap { список in
    //            основнойАлгоритм(координаты, объектКарты, список2)
    //        }
    //    default:
    //        основнойАлгоритм(координаты, объектКарты, список)
    //
    
    
    
    
    
    
    
    //v2
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        
        let responce = MapData.query(on: request)
            .filter(\MapData.name == mapName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping MapData error"))).map(to: Response.self) { mapObject  in
                    
                    
                    let outputData = controller.findTile(mapName, xText, yText, zoom, mapObject)
                    
                    print(outputData)
                    
                    switch outputData {
                        
                    case .redirect(let url):
                        return request.redirect(to: url)
                        
                        
                    case .image(let imageData, let extention):
                        // It works with png and jpg???
                        return request.makeResponse(imageData, as: MediaType.png)
                        
                        /*
                         if (extention == "png") {
                         return req.makeResponse(imageData, as: MediaType.png)
                         } else if (extention == "jpg") || (extention == "jpeg") {
                         return req.makeResponse(imageData, as: MediaType.jpeg)
                         } else {
                         return req.makeResponse(imageData, as: MediaType.png)
                         //throw "Unsupportable loaded file extention"
                         }
                         */
                        
                    case .error(let desctiption):
                        print(desctiption)
                        return request.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: desctiption), body: ""))
                    }
                }
        
        
        return responce
        
    }
    
    
    
    
    
    //Пример выполнения всей функциональности в одном запросе
    /*
     router.get("cats", Int.parameter) { req -> String in
     let intParam = try req.parameters.next(Int.self)
     let bangkokQuery:String = try req.query.get(at: ["district"])
     return "You have requested route /cats/\(intParam)"
     }
     */
    
    
    //=======================
    
  /*
    router.get("img") { request -> Future<Response> in
//        let responce = request.redirect(to: "img/0.png")
//        let responce = request.redirect(to: "https://tiles.nakarte.me/ggc2000/10/615/702")
        
//        guard let data = try? request.client().get("https://tiles.nakarte.me/ggc2000/10/615/702") else {return request.response(http: HTTPResponse(status: .notFound))}
        
        let data = try request.client().get("https://tiles.nakarte.me/ggc2000/10/615/702")
        
       
        let a = data.map(to: Response.self) { d in
            
            let res = HTTPResponse(status: .ok, body: d as! LosslessHTTPBodyRepresentable)
            let responce = request.response(http: res)
            return responce
        }
        
        
        
        return a
        
        //let responce = request.makeResponse(data, as: MediaType.png)
        //let responce = request.response(http: data)
        
//        let res = HTTPResponse(status: .ok, body: data as! LosslessHTTPBodyRepresentable)
//        let responce = request.response(http: res)
//        return responce
    }
 */
    
//    router.get("test", use: controller.uploadUser2)
    
    
    
    
    
    
    
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    router.get("test") { req -> Response in
        
        let str = "Super long string here again"
//        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
//        let filename = URL(fileURLWithPath: "/Public/123.txt")
        
//        //let url = URL(fileURLWithPath: "https://a.tile.opentopomap.org/1/0/0.png")
//        let url = URL(string: "https://a.tile.opentopomap.org/1/0/0.png")
//        //let data = try req.client().get("https://tiles.nakarte.me/ggc2000/10/615/702")
//        let data = try? Data(contentsOf: url!)
        
        let directory = DirectoryConfig.detect()
        let filename = URL(fileURLWithPath: directory.workDir)
            .appendingPathComponent("Public", isDirectory: true)
            .appendingPathComponent("123.txt")
//            .appendingPathComponent("321.png")
        
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
//            try data?.write(to: filename)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        
        
        /*
        let data = try Storage.get(path: "https://tiles.nakarte.me/ggc2000/10/615/702", on: req)
       
        try Storage.upload(dataURI: "https://tiles.nakarte.me/ggc2000/10/615/702", on: req)

        
        let res = try req.client().get("http://vapor.codes")
        
        let bytes = data
        try Storage.upload(
            bytes: "qwe",
            fileName: "profile.png",
            on: req
        )
        
        */
        //return "Welcome to AnyGIS!"
        //return filename.absoluteString
        return req.redirect(to: "123.txt")
    }
    
    
    
    router.get("loadAndShowImage") { req -> Response in
        
        let url = URL(string: "https://a.tile.opentopomap.org/1/0/0.png")
        let data = try? Data(contentsOf: url!)
        
        let fileName = "myImage.png"
        let directory = DirectoryConfig.detect()
        
        let filePatch = URL(fileURLWithPath: directory.workDir)
            .appendingPathComponent("Public", isDirectory: true)
            .appendingPathComponent(fileName)
        
        do {
            try data?.write(to: filePatch)
        } catch {
            // error handling
        }
        
        return req.redirect(to: fileName)
    }
    
    */
    
    router.get("red") { req -> Response in
        
        let url = URL(string: "https://a.tile.opentopomap.org/1/0/0.png")
        
        do {
            let data = try Data(contentsOf: url!)
            let response: Response = req.makeResponse(data, as: MediaType.png)
            return response
        } catch {
            let errorResponce = HTTPResponse(status: .internalServerError)
            let response = req.makeResponse(http: errorResponce)
            return response
        }
    }
    
    
//    router.get("showImage") { req -> Future<Response> in
//
//        do {
//            let data = try req.client().get("https://a.tile.opentopomap.org/1/0/0.png")
//            return data
//        } catch {
//            throw Abort(.badRequest, reason: "Image data reading error")
//        }
//    }
    
    
    
    
    //        let directory = DirectoryConfig.detect()
    //        let filePatch = URL(fileURLWithPath: directory.workDir)
    //            .appendingPathComponent("Public", isDirectory: true)
    //            .appendingPathComponent("myImage.png")


// Thanks. I'll try to think of something. I have another question. I got the data from URL. Now I don't understand how to get to the it's content with the image data?  I need to process this image and return it to the user.

//```swift
    /*
    router.get("showImage") { req -> Future<Response> in
        do {
            let futureResponce = try req.client().get("https://a.tile.opentopomap.org/1/0/0.png")
            
            let imageData = // Some magic transormatinos =)
            
            let transformedImageData = process(imageData)

            let resultingResponse = req.makeResponse(transformedImageData, as: MediaType.png)
            
            return resultingResponse
            
        } catch {
            // error handling
        }
    }
    */
//```
    
  
    
    // I tried that, but it didn't work.
    
    //```swift
    
    // Вариант по ответам с форума !!!
    
    router.get("showImage2") { req -> Future<Response> in
        do {
            let futureResponce = try req.client().get("https://a.tile.opentopomap.org/1/0/0.png")
            
            let futureData = futureResponce.flatMap { $0.http.body.consumeData(on: req) }
            
            let resultResponce = futureData.map(to: Response.self) { data in
                
                // some transformations with image data
                let newImageData = data
                let response = req.makeResponse(newImageData, as: MediaType.png)
                return response
            }
            
            return resultResponce

            
        } catch {
            throw Abort(.badRequest, reason: "Image data reading error")
        }
    }
    
    
    struct CloudinaryPostMessage: Content {
        var file: String
        var public_id: String
        var upload_preset: String
    }
    
    
    router.get("cloudinary") { request -> Response in
                
        let message = CloudinaryPostMessage(file: "https://a.tile.opentopomap.org/1/0/0.png", public_id: "321321", upload_preset: "guestPreset")
        
        let responce = try request.client().post("https://api.cloudinary.com/v1_1/nnngrach/image/upload") { loginReq in
            // encode the loginRequest before sending
            try loginReq.content.encode(message)
        }
        
        print("==================")
        print(responce)
        
        return request.redirect(to: "https://res.cloudinary.com/nnngrach/image/upload/321321")
    }
    
    
            
            
    
//    func simpleBlurFilterExample(inputImage: UIImage) -> UIImage {
//        // convert UIImage to CIImage
//        let inputCIImage = CIImage(image: inputImage)!
//
//        // Create Blur CIFilter, and set the input image
//        let blurFilter = CIFilter(name: "CIGaussianBlur")!
//        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
//        blurFilter.setValue(8, forKey: kCIInputRadiusKey)
//
//        // Get the filtered output image and return it
//        let outputImage = blurFilter.outputImage!
//        return UIImage(ciImage: outputImage)
//    }
    
            
    
    
    
    
 /*
            let transformedImageFutureData = futureResponce.flatMap(to: Data.self) { responce in
                do {
                    let imageFutureData = try responce.content.decode(Data.self).map { data -> Data in
                        print("All Image data transformations will be here")
                        print("but this print don't works")
                        return data
                    }
                    return imageFutureData
                    
                } catch {
                    print("Again it don't work")
                    throw Abort(.badRequest, reason: "Image data reading error")
                }
            }
            
            
            return futureResponce
            
        } catch {
            throw Abort(.badRequest, reason: "Image data reading error")
        }
 */
//    }
    
//```
    
    

}

//```swift
//// router.swift
//
//import Foundation
//import Vapor
//import FluentSQLite
//
//
//public func routes(_ router: Router) throws {
//
//    router.get("showImage") { req -> Response in
//
//        let url = URL(string: "https://a.tile.opentopomap.org/1/0/0.png")
//
//        do {
//            let data = try Data(contentsOf: url!)
//            let response: Response = req.makeResponse(data, as: MediaType.png)
//            return response
//        } catch {
//            let errorResponce = HTTPResponse(status: .internalServerError)
//            let response = req.makeResponse(http: errorResponce)
//            return response
//        }
//    }
//}
//```
