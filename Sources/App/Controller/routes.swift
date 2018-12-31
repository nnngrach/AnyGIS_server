import Foundation
import Vapor
import FluentSQLite


/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let baseHandler = BaseHandler()
    let imageProcessor = ImageProcessor()
    let controller = TilePatchCreator()
    let coordinateTransformer = CoordinateTransformer()
    
    
    // Welcome screen
    router.get { req -> Future<View> in
        return try req.view().render("home")
    }
    
    
    // Show html table with all maps
    router.get("list") { req -> Future<View> in
        let databaseMaps = baseHandler.fetchAllMapsList(req)
        return try req.view().render("tableMaps", ["databaseMaps": databaseMaps])
    }
    
    
    router.get("overlay_list") { req -> Future<View> in
        let databaseMaps = baseHandler.fetchOverlayMapsList(req)
        return try req.view().render("tableOverlay", ["databaseMaps": databaseMaps])
    }
    


    
    // Statring of the main algorithm
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
    
        
        let mapData = try baseHandler.getBy(mapName: mapName, request)

        
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            switch mapObject.mode {
            case "redirect":
                
                let tileNumbers = try coordinateTransformer.getTileNumbers(xText, yText, zoom)
                
                let newUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject)
                
                return try request.redirect(to: newUrl).encode(for: request)
                
                
                            
                            
            case "overlay":
                
                let tileNumbers = try coordinateTransformer.getTileNumbers(xText, yText, zoom)
               
                let mapList = try baseHandler.getOverlayBy(setName: mapName, request)
                
                
                let responce = mapList.flatMap(to: Response.self) { mapListData  in
                
                    let baseMapName = mapListData.baseName
                    let overlayMapName = mapListData.overlayName
                    let baseMapData = try baseHandler.getBy(mapName: baseMapName, request)
                    let overlayMapData = try baseHandler.getBy(mapName: overlayMapName, request)
                    
                    
                    //Synchronization...
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                
                            let baseUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject)
                            
                            let overlayUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject)
                            
                            let loadingResponces = try imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], request)
                            
                            return imageProcessor.syncTwo(loadingResponces, request) { res in
                                
                                let newUrl = imageProcessor.getUrlOverlay(baseUrl, overlayUrl)
                                return try! request.redirect(to: newUrl).encode(for: request)
                            }
                        }
                    }
                }
                return responce

                
                
                

                
            case "wgs84":
                
                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                
                
                let fourTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject)
                
                let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                
                
                
                return imageProcessor.syncFour(loadingResponces, request) { res in
                    
                    let processedImageUrl = imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                    
                    return try! request.redirect(to: processedImageUrl).encode(for: request)
                }
                
                
        
        
        

            case "wgs84_overlay":

                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                let mapList = try baseHandler.getOverlayBy(setName: mapName, request)
                
                
                let responce = mapList.flatMap(to: Response.self) { mapListData  in
                    
                    let baseMapName = mapListData.baseName
                    let overlayMapName = mapListData.overlayName
                    let baseMapData = try baseHandler.getBy(mapName: baseMapName, request)
                    let overlayMapData = try baseHandler.getBy(mapName: overlayMapName, request)
                    
                    
                    //Synchronization...
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                            
                            let fourTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject)
                            
                            let fourOverTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject)
                            
                            
                            let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                            
                            let loadingOverResponces = try imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, request)
                            
                            
                            return imageProcessor.syncFour(loadingResponces, request) { res1 in
                                return imageProcessor.syncFour(loadingOverResponces, request) { res2 in
                                    
                                    let processedImageUrl = imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                                    
                                    return try! request.redirect(to: processedImageUrl).encode(for: request)
                                }
                            }
                        }
                    }
                }
                return responce
                
                
                
                
                
                
           
         
                
        
        
        
        
/*
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
         
         
                 
            case "traffik":
                break
                 
            case "custom":
                 break

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
    
    
    

    
    
    
    /*
     router.get("opacity", Int.parameter, String.parameter) { request -> Future<Response> in
     
     let opacity = try request.parameters.next(Int.self)
     let url = try request.parameters.next(String.self)
     print(opacity)
     print(url)
     
     //        guard (0...100).contains(opacity) else {
     //            return try makeErrorResponce("Opacity must be in 0...100", request).encode(for: request)
     //        }
     
     
     let res = try imageProcessor.upload(url, request)
     
     let responce = res.flatMap(to: Response.self) { q  in
     let name = imageProcessor.makeName(url)
     let newUrl = imageProcessor.getUrlWithOpacity(name, opacity)
     return try! request.redirect(to: newUrl).encode(for: request)
     }
     
     
     return responce
     }
     */
    
    
    
    
    
    
   
    
  /*
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
   */
    
    
    
  
    
    
    
    
    
    
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
