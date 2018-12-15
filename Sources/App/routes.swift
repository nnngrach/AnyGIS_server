import Foundation
import Vapor
import FluentSQLite
//import UIKit
//import Storage

/// Register your application's routes here.
public func routes(_ router: Router) throws {


    
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
    
    struct CloudinaryImgUrl: Content {
        var url: String
    }
    
    
    router.get("uploadAndRedirect") { req -> Future<Response> in
        
        let name = "myImageName"
        let host = "https://api.cloudinary.com/v1_1/nnngrach/image/upload"
        
        let message = CloudinaryPostMessage(file: "https://a.tile.opentopomap.org/3/0/0.png",
                                            public_id: name,
                                            upload_preset: "guestPreset")

        
        let futResponse = try req.client().post(host) { postReq in
            try postReq.content.encode(message)
        }
        
        let futureData = futResponse.flatMap { $0.http.body.consumeData(on: req) }
       
        
        let redirectingRespocence = futResponse.flatMap(to: Response.self) { res in
            let futContent = try res.content.decode(CloudinaryImgUrl.self)
            
            let newResponce = futContent.map(to: Response.self) { content in
                let loadedImageUrl = content.url
                return req.redirect(to: loadedImageUrl)
            }
            
            return newResponce
        }
        
        return redirectingRespocence
    }
   
    
    
 
}
