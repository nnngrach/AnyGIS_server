import Foundation
import Vapor
import FluentSQLite
//import AppKit


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
    
    
    router.get("priority_list") { req -> Future<View> in
        let databaseMaps = baseHandler.fetchPriorityMapsList(req)
        return try req.view().render("tablePriority", ["databaseMaps": databaseMaps])
    }
    



    
    // Statring of the main algorithm
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
    
        
        let mapData = try baseHandler.getBy(mapName: mapName, request)

        
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return notFoundResponce(request)}
            guard zoom >= mapObject.zoomMin else {return notFoundResponce(request)}
            
            switch mapObject.mode {
            case "redirect":
                
                let tileNumbers = try coordinateTransformer.getTileNumbers(xText, yText, zoom)
                
                let newUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)

                return redirect(to: newUrl, with: request)
                
                
                            
                            
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
                
                            let baseUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let overlayUrl = controller.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            let loadingResponces = try imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], request)
                            
                            return imageProcessor.syncTwo(loadingResponces, request) { res in
                                
                                let newUrl = imageProcessor.getUrlOverlay(baseUrl, overlayUrl)
                                return redirect(to: newUrl, with: request)
                            }
                        }
                    }
                }
                return responce

                
                
                

                
            case "wgs84":
                
                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                
                
                let fourTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
                
                let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                
                
                
                return imageProcessor.syncFour(loadingResponces, request) { res in
                    
                    let processedImageUrl = imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                    
                    return redirect(to: processedImageUrl, with: request)
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
                            
                            let fourTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let fourOverTilesAroundUrls = controller.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            
                            let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                            
                            let loadingOverResponces = try imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, request)
                            
                            
                            return imageProcessor.syncFour(loadingResponces, request) { res1 in
                                return imageProcessor.syncFour(loadingOverResponces, request) { res2 in
                                    
                                    let processedImageUrl = imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                                    
                                    return redirect(to: processedImageUrl, with: request)
                                }
                            }
                        }
                    }
                }
                return responce
                
                
                
            
                
                
            case "checkAllMirrors":
                
                let tileNumbers = try coordinateTransformer.getTileNumbers(xText, yText, zoom)
                
                let mapList = try baseHandler.getMirrorsListBy(setName: mapName, request)
                
                let responce = mapList.flatMap(to: Response.self) { mapSetData  in
                    
                    guard mapSetData.count != 0 else {return notFoundResponce(request)}
                    
                    let startIndex = 0
                    //let urls = mapSetData.map {$0.url}
                    let urls = ["a", "b", "c"]
                    let shufledUrls = herokuShuffled(array: urls)
                    print(shufledUrls)
                    let firstExistingUrl = try checkMirrorExist(shufledUrls, startIndex, tileNumbers.x, tileNumbers.y, zoom, request)
                    
                    return firstExistingUrl.flatMap(to: Response.self) {url in
                        guard url != "notFound" else {return notFoundResponce(request)}
                        return redirect(to: url, with: request)
                    }
                }
                return responce
 

                
                
                

            case "mapSet":
                
                let tileNumbers = try coordinateTransformer.getTileNumbers(xText, yText, zoom)
                
                let mapList = try baseHandler.getPriorityListBy(setName: mapName, zoom: zoom, request)
                
                let responce = mapList.flatMap(to: Response.self) { mapSetData  in
                    
                    guard mapSetData.count != 0 else {return notFoundResponce(request)}
                    
                    let startIndex = 0
                    let firstExistingUrl = try checkTileExist(mapSetData, startIndex, tileNumbers.x, tileNumbers.y, zoom, request)
                    
                    return firstExistingUrl.flatMap(to: Response.self) {url in
                        guard url != "notFound" else {return notFoundResponce(request)}
                        return redirect(to: url, with: request)
                    }
    
                }
                return responce
                
            

                
                

            default:
                return errorResponce("Unknown value MapMode in data base", request)
            }
        
        }
        
        return responce
        
    }
    
    
    
    
    
    
    func errorResponce (_ description: String, _ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: description), body: "")).encode(for: req)
    }
    
    
    func notFoundResponce (_ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .notFound, body: "")).encode(for: req)
    }
    
    
    func redirect(to url: String, with req: Request) -> Future<Response>  {
        return try! req.redirect(to: url).encode(for: req)
    }

    
 
    
    
    
    
    func checkTileExist(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ request: Request) throws -> Future<String> {
        
        let currentMapName = maps[index].mapName
        
        let baseMapData = try baseHandler.getBy(mapName: currentMapName, request)
        
        
        let existingUrl = baseMapData.flatMap(to: String.self) { mapObject  in
            
            //check2 - сократить!
            
            let currentMapUrl = controller.calculateTileURL(x, y, z, mapObject.backgroundUrl, mapObject.backgroundServerName)
            
            let response = try! request.client().get(currentMapUrl)
            
            return response.flatMap(to: String.self) { res -> Future<String> in
                
                if res.http.status.code != 404 {
                    return request.future(currentMapUrl)
                    
                } else if index+1 < maps.count  {
                    let nextIndex = index + 1
                    let recursiveFoundedUrl = try checkTileExist(maps, nextIndex, x, y, z, request)
                    return recursiveFoundedUrl
                    
                } else {
                    return request.future("notFound")
                }
            }
        }
        return existingUrl
    }
    
    
    
    
    func checkMirrorExist(_ urls: [String], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ request: Request) throws -> Future<String> {
        
        let currentTemplateUrl = urls[index]
        let currentResultUrl = controller.calculateTileURL(x, y, z, currentTemplateUrl, "")
        let response = try! request.client().get(currentResultUrl)
        
        return response.flatMap(to: String.self) { res -> Future<String> in
            
            if res.http.status.code != 404 {
                print("result " + currentResultUrl)
                return request.future(currentResultUrl)
                
            } else if index+1 < urls.count  {
                print("next " + currentResultUrl)
                let nextIndex = index + 1
                let recursiveFoundedUrl = try checkMirrorExist(urls, nextIndex, x, y, z, request)
                return recursiveFoundedUrl
                
            } else {
                print("finish " + currentResultUrl)
                return request.future("notFound")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    // ===========================================
    
    
    //let sortedMaps = db.fetch()
    
//    func checkTileExist(urls: [String], index: Int, request: Request) -> Future<String> {
//
//        let currentUrl = urls[index]
//        let response = try! request.client().get(currentUrl)
//        let result = response.flatMap(to: String.self) { res -> Future<String> in
//
//            if res.http.status.code != 404 {
//                return request.future(currentUrl)
//
//            } else if index+1 < urls.count  {
//                let futureString = checkTileExist(urls: urls, index: index + 1, request: request)
//                return futureString
//
//            } else {
//                return request.future("default")
//            }
//
//        }
//
//        return result
//    }
    

    
    

    
    

 
    
    /*
    // ответ с форума
    func test2(req: Request) {
        let fileExists = HTTPClient.connect(hostname: "domain.com", on: req).flatMap { (client) -> Future<Bool> in
            let request = HTTPRequest(method: .HEAD, url: "/image.png")
            return client.send(request).map({ (response) in
                return response.status.code == 200
            })
        }
    }
    
    func test3(host: String, url: String, req: Request) -> Future<Bool> {
        print("test3")
        let fileExists = HTTPClient.connect(hostname: host, on: req).flatMap { (client) -> Future<Bool> in
            print(client)
            print("q")
            
            let request = HTTPRequest(method: .HEAD, url: url)
            print(request)
            print("2")
            
            return client.send(request).map({ (response) in
                print("e")
                print(response)
                print(response.status.code)
                return response.status.code == 200
            })
        }
        print("r")
        return fileExists
    }
 
 */
 
 
 
 
 
    
    
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
