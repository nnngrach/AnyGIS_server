import Foundation
import Vapor
import FluentSQLite


/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let baseHandler = BaseHandler()
    let imageProcessor = ImageProcessor()
    let controller = IndependentController()
    
  
    
    // TODO: Возвращать не просто текст из переменной
    // (тем более, глобальной и публичной), а HTML страничку
    router.get { req in
        return instructionText
    }

    // TODO: Возвращать не JSON, а HTML - таблицу
    // вернуть таблицу с названием всех карт и их описанием
    router.get("list", use: baseHandler.listJSON)
    router.get("list2", use: baseHandler.listOverlayJSON)

    
    
    
    //Запуск главного алгоритма - v2
    
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        
        
//        let responce = MapData.query(on: request)
//            .filter(\MapData.name == mapName)
//            .first()
//            .unwrap(or: Abort.init(
//                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Uwarping MapData error"))).map(to: Response.self) { mapObject  in
        
        
        
        let mapData = try baseHandler.getBy(mapName: mapName, request)

        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
                    var outputData: ProcessingResult
            
            
                    //свитч пока что не работает
                    switch mapObject.mode {
                    case "redirect":
                        guard let newUrl = controller.findTile(mapName, xText, yText, zoom, mapObject) else { return try makeErrorResponce("Unvarping URL Error", request).encode(for: request) }
                        
                        return try request.redirect(to: newUrl).encode(for: request)
                        
                        
                        
                    case "overlay":
                       
                        let mapList = try baseHandler.getOverlayBy(setName: mapName, request)
                        
                        let responce = mapList.flatMap(to: Response.self) { mapListData  in
                        
                            let baseMapName = mapListData.baseName
                            let overlayMapName = mapListData.overlayName
                            
                            let baseMapData = try baseHandler.getBy(mapName: baseMapName, request)
                            let overlayMapData = try baseHandler.getBy(mapName: overlayMapName, request)
                            
                            
                            //Synchronization...
                            return baseMapData.flatMap(to: Response.self) { baseObject  in
                                return overlayMapData.flatMap(to: Response.self) { overObject  in
                        
                                    
                                    guard let baseUrl = controller.findTile(baseMapName, xText, yText, zoom, baseObject) else { return try makeErrorResponce("Unvarping URL Error", request).encode(for: request) }
                                    
                                    guard let overlayUrl = controller.findTile(overlayMapName, xText, yText, zoom, overObject) else { return try makeErrorResponce("Unvarping URL Error", request).encode(for: request) }
                                    
                                    
                                    let baseLoadingResponce = try imageProcessor.upload(sourceUrl: baseUrl, request: request)
                                    
                                    let overlayLoadingResponce = try imageProcessor.upload(sourceUrl: overlayUrl, request: request)
                                    
                                    
                                    // Synchronization...
                                    let imageUrl = baseLoadingResponce.flatMap(to: Response.self) { res1 in
                                        return overlayLoadingResponce.map(to: Response.self) { res2 in
                                            
                                            
                                            let baseImgName = imageProcessor.makeName(sourceUrl: baseUrl)
                                            let overlayImgName = imageProcessor.makeName(sourceUrl: overlayUrl)
                                            
                                            return request.redirect(to: "https://res.cloudinary.com/nnngrach/image/upload/l_\(overlayImgName),o_100/\(baseImgName)")
                                        }
                                    }
                                    return imageUrl
                                }
                                //return res2
                            }
                          //return res1
                        }
                        return responce
 
                        
/*
                        
                    case "wgs84":
                        //получить координаты и смещение
                        //получить массив из 4-х ссылок
                        //return imageHandler.mooveWgs84([urls], [offsets]])
                        return request.redirect(to: "")
                        
                    case "wgs84_overlay":
                        //получить координаты и смещение
                        //получить массив из 4-х ссылок
                        //получить массив из 4-х ссылок
                        //return imageHandler.mooveWgs84([urls1], [urls2], [offsets]])
                        return request.redirect(to: "")
                        
                    case "mapSet":
                        //получить из базы отсортированный массив карт для текущего масшаба
                        //если карт больше, чем 1, то
                        
                        // for map in maps {
                        //   baseHandler.find(map) { mapData in
                        //      let url = process(xyz,mapData)
                        //      let finished = checkTileExisting(url)
                        //      if finished {return redirect(url)}
                        //      }
                        // }
                        return request.redirect(to: "")

*/
                    default:
                        return try makeErrorResponce("Unknown value MapMode in data base", request).encode(for: request)
                    }
            
                }
        
        return responce
        
    }
    
    
    
    
    func makeErrorResponce (_ description: String, _ req: Request) -> Response {
        return req.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: description), body: ""))
    }
    
    
    
    //========================================
    // Работа с сервисом Cloudinary
    // Для загрузки и обработки картинок на лету
    
    
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
    
    
    
    
    
    
    
    //========================
    
    //    router.get(String.parameter, String.parameter, String.parameter,Int.parameter, use: vaporController.startFindingTile)
    
    
    // Запуск главного алгоритма v1
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
    
    
    
    
    
    //    Вернуть изображение по ссылке с указанным значение прозрачности
    //    router.get("opacity", Double.parameter, String.parameter, use: controller.splitter)

    
    
    
    //Пример выполнения всей функциональности в одном запросе
    /*
     router.get("cats", Int.parameter) { req -> String in
     let intParam = try req.parameters.next(Int.self)
     let bangkokQuery:String = try req.query.get(at: ["district"])
     return "You have requested route /cats/\(intParam)"
     }
     */
    
    
    //=======================
    
    
    
    
 

    // Вариант получения картинки по ответам с форума !!!
    /*
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
    */
    
    
    
    
    
 
   
    
    
 
}
