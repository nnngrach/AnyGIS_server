import Foundation
import Vapor
import FluentSQLite
//import AppKit


/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let sqlHandler = SQLHandler()
    let imageProcessor = ImageProcessor()
    let urlPatchCreator = URLPatchCreator()
    let coordinateTransformer = CoordinateTransformer()
    
    
    // MARK: Html pages
    
    // Show welcome "index" page.
    // Here I'm using "Leaf" Html-page generator.
    // Patch:  ...\Resources\Views\*.leaf
    router.get { req -> Future<View> in
        return try req.view().render("home")
    }
    
    
    // Show html table with list of all maps
    router.get("list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchAllMapsList(req)
        return try req.view().render("tableMaps", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with list of mirrors for some maps
    router.get("mirrors_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchMirrorsMapsList(req)
        return try req.view().render("tableMirrors", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with layers for overlay maps
    router.get("overlay_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchOverlayMapsList(req)
        return try req.view().render("tableOverlay", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with layers for "Combo-mode" maps
    router.get("priority_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchPriorityMapsList(req)
        return try req.view().render("tablePriority", ["databaseMaps": databaseMaps])
    }
    



    
    // MARK: Statring of the main algorithm
    
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        // Extracting values from URL parameters
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
    
        // Load map informarion from database in Future format
        let mapData = try sqlHandler.getBy(mapName: mapName, request)

        
        // Synchronizing map information
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return notFoundResponce(request)}
            guard zoom >= mapObject.zoomMin else {return notFoundResponce(request)}
            
            // Select processing mode
            switch mapObject.mode {
                
                
            case "redirect":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)

                return redirect(to: newUrl, with: request)
                
                
                            
                            
            case "overlay":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
               
                // Load layers info from data base in Future format
                let layers = try sqlHandler.getOverlayBy(setName: mapName, request)
                
                // Synchronization Futrure to data object.
                // Generating redirect URL-response to processed image.
                let redirectingResponce = layers.flatMap(to: Response.self) { layersData  in
                
                    // Load info for every layers from data base in Future format
                    let baseMapName = layersData.baseName
                    let overlayMapName = layersData.overlayName
                    let baseMapData = try sqlHandler.getBy(mapName: baseMapName, request)
                    let overlayMapData = try sqlHandler.getBy(mapName: overlayMapName, request)
                    
                    
                    // Synchronization Futrure to data object.
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                
                            let baseUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let overlayUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            // Upload all images to online image-processor
                            let loadingResponces = try imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], request)
                            
                            // Redirect to URL of resulting file in image-processor storage
                            return imageProcessor.syncTwo(loadingResponces, request) { res in
                                
                                let newUrl = imageProcessor.getUrlOverlay(baseUrl, overlayUrl)
                                return redirect(to: newUrl, with: request)
                            }
                        }
                    }
                }
                return redirectingResponce

                
                
                

                
            case "wgs84":
                
                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                
                // To make image with offset I'm cropping one image from four nearest images.
                let fourTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
                
                // Upload all images to online image-processor
                let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                
                
                // Get URL of resulting file in image-processor storage
                let redirectingResponce = imageProcessor.syncFour(loadingResponces, request) { res in
                    
                    let processedImageUrl = imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                    
                    return redirect(to: processedImageUrl, with: request)
                }
                
                return redirectingResponce
                
        
        
        

            case "wgs84_overlay":

                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                // Load layers info from data base in Future format
                let mapList = try sqlHandler.getOverlayBy(setName: mapName, request)
                
                // Synchronization Futrure to data object.
                // Generating redirect URL-response to processed image.
                let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
                    
                    // Load info for every layers from data base in Future format
                    let baseMapName = mapListData.baseName
                    let overlayMapName = mapListData.overlayName
                    let baseMapData = try sqlHandler.getBy(mapName: baseMapName, request)
                    let overlayMapData = try sqlHandler.getBy(mapName: overlayMapName, request)
                    
                    
                    // Synchronization Futrure to data object.
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                            
                            // To make one image with offset I need four nearest to crop.
                            let fourTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let fourOverTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            // Upload all images to online image-processor
                            let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, request)
                            
                            let loadingOverResponces = try imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, request)
                            
                            // Get URL of resulting file in image-processor storage
                            return imageProcessor.syncFour(loadingResponces, request) { res1 in
                                return imageProcessor.syncFour(loadingOverResponces, request) { res2 in
                                    
                                    let processedImageUrl = imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                                    
                                    return redirect(to: processedImageUrl, with: request)
                                }
                            }
                        }
                    }
                }
                return redirectingResponce
                
                
                
            
                
                
            case "checkAllMirrors":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                // Load info for every mirrors from data base in Future format
                let mirrorsList = try sqlHandler.getMirrorsListBy(setName: mapName, request)
                
                // Synchronization Futrure to data object.
                let redirectingResponce = mirrorsList.flatMap(to: Response.self) { mirrorsListData  in
                    
                    guard mirrorsListData.count != 0 else {return notFoundResponce(request)}
                    
                    let urls = mirrorsListData.map {$0.url}
                    let hosts = mirrorsListData.map {$0.host}
                    let patchs = mirrorsListData.map {$0.patch}
                    let ports = mirrorsListData.map {$0.port}
                    
                    // Custom random iterating of array
                    let startIndex = 0
                    let shuffledOrder = makeShuffledOrder(maxNumber: mirrorsListData.count)
                    let firstCheckingIndex = shuffledOrder[startIndex] ?? 0
                    var firstFoundesFileIndex : EventLoopFuture<Int?>

                    
                    // File checker
                    if hosts[firstCheckingIndex] == "dont't need to check" {
                        // Global maps. Dont't need to check it
                        firstFoundesFileIndex = request.future(firstCheckingIndex)
                        
                    } else {
                        // Local maps. Start checking of file existing for all mirrors URLs
                        firstFoundesFileIndex = checkUrlStatus(index: startIndex, hosts, ports, patchs, tileNumbers.x, tileNumbers.y, zoom, shuffledOrder, req: request)
                    }
                    
                    
                    // Generate URL for founded file and redirect to it
                    return firstFoundesFileIndex.flatMap(to: Response.self) { i in
                        guard let index = i else {return notFoundResponce(request)}
                        
                        let checkedUrl = urls[index] //Shuffled?
                        let currentMapUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, checkedUrl, "")
                        return redirect(to: currentMapUrl, with: request)
                    }
                }
                return redirectingResponce
 

                
                
                

            case "mapSet":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                // Load info for every layers from data base in Future format
                let layersList = try sqlHandler.getPriorityListBy(setName: mapName, zoom: zoom, request)
                
                // Synchronization Futrure to data object.
                let redirectingResponce = layersList.flatMap(to: Response.self) { layersListData  in
                    
                    guard layersListData.count != 0 else {return notFoundResponce(request)}
                    
                    // Start checking of file existing for all layers URLs
                    let startIndex = 0
                    let firstExistingUrl = try checkTileExist(layersListData, startIndex, tileNumbers.x, tileNumbers.y, zoom, request)
                    
                    // Redirect to URL for first founded file
                    return firstExistingUrl.flatMap(to: Response.self) {url in
                        guard url != "notFound" else {return notFoundResponce(request)}
                        return redirect(to: url, with: request)
                    }
    
                }
                return redirectingResponce
                
            

                
                

            default:
                return errorResponce("Unknown value MapMode in data base", request)
            }
        
        }
        
        return responce
        
    }
    
    
    
    
    
    // MARK: Html functions
    
    func errorResponce (_ description: String, _ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: description), body: "")).encode(for: req)
    }
    
    
    func notFoundResponce (_ req: Request) -> Future<Response> {
        return try! req.response(http: HTTPResponse(status: .notFound, body: "")).encode(for: req)
    }
    
    
    func redirect(to url: String, with req: Request) -> Future<Response>  {
        return try! req.redirect(to: url).encode(for: req)
    }

    
 
    
    
    // MARK: File existing checker by URL
    
    func checkTileExist(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ request: Request) throws -> Future<String> {
        
        let currentMapName = maps[index].mapName
        
        let baseMapData = try sqlHandler.getBy(mapName: currentMapName, request)
        
        
        let existingUrl = baseMapData.flatMap(to: String.self) { mapObject  in
            
            //check2 - сократить!
            
            let currentMapUrl = urlPatchCreator.calculateTileURL(x, y, z, mapObject.backgroundUrl, mapObject.backgroundServerName)
            
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
    
    
    
    
    func checkUrlStatus(index: Int, _ hosts: [String], _ ports: [String], _ patchs: [String], _ x: Int, _ y: Int, _ z: Int, _ order: [Int:Int], req: Request) -> Future<Int?> {
        
        guard let shuffledIndex = order[index] else {return req.future(nil)}
        
        var connection: EventLoopFuture<HTTPClient>
        
        if ports[shuffledIndex] == "any" {
            connection = HTTPClient.connect(hostname: hosts[shuffledIndex], on: req)
        } else {
            let portNumber = Int(ports[shuffledIndex]) ?? 8088
            connection = HTTPClient.connect(hostname: hosts[shuffledIndex], port: portNumber, connectTimeout: .milliseconds(100), on: req)
        }
        
        
        return connection.flatMap { (client) -> Future<Int?> in
                
                let currentUrl = urlPatchCreator.calculateTileURL(x, y, z, patchs[shuffledIndex], "")
                
                let request = HTTPRequest(method: .HEAD, url: currentUrl)
                
                return client.send(request).flatMap({ (response) -> Future<Int?> in
                    
                    if response.status.code != 404 {
                        //print ("good ", hosts[shuffledIndex], currentUrl)
                        return req.future(shuffledIndex)
                        
                    } else if (index + 1) < hosts.count {
                        //print ("bad ", hosts[shuffledIndex], currentUrl)
                        return checkUrlStatus(index: index+1, hosts, ports, patchs, x, y, z, order, req: req)
                        
                    } else {
                        //print("stop")
                        return req.future(nil)
                    }
                })
        }
    }
    
    

    

    
    
//=======================
    
    

 
    
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
