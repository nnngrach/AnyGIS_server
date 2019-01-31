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
    
    
    router.get("ping") { req -> String in
        return "Ping!"
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

    



    
    // MARK: Main request to get tile image
    
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        // Extracting values from URL parameters
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        let httpResponse =  try startSearchingForMap(mapName, xText: xText, yText, zoom, request)
        
        return httpResponse
    }
    
    
    
    
    
    
    
    
    
    
    // Statring of the main algorithm
    
    func startSearchingForMap(_ mapName: String, xText:String, _ yText: String, _ zoom: Int, _ req: Request) throws -> Future<Response>  {
        
        // Load map informarion from database in Future format
        let mapData = try sqlHandler.getBy(mapName: mapName, req)
        
        
        // Synchronizing map information
        let responce = mapData.flatMap(to: Response.self) { mapObject  in
            
            guard zoom <= mapObject.zoomMax else {return notFoundResponce(req)}
            guard zoom >= mapObject.zoomMin else {return notFoundResponce(req)}
            
            
            // Select processing mode
            switch mapObject.mode {
                
                
            case "redirect":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                let newUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, mapObject.backgroundUrl, mapObject.backgroundServerName)
                
                return redirect(to: newUrl, with: req)
                
                
                
                
            case "overlay":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                // Load layers info from data base in Future format
                let layers = try sqlHandler.getOverlayBy(setName: mapName, req)
                
                // Synchronization Futrure to data object.
                // Generating redirect URL-response to processed image.
                let redirectingResponce = layers.flatMap(to: Response.self) { layersData  in
                    
                    // Load info for every layers from data base in Future format
                    let baseMapName = layersData.baseName
                    let overlayMapName = layersData.overlayName
                    let baseMapData = try sqlHandler.getBy(mapName: baseMapName, req)
                    let overlayMapData = try sqlHandler.getBy(mapName: overlayMapName, req)
                    
                    
                    // Synchronization Futrure to data object.
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                            
                            let baseUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let overlayUrl = urlPatchCreator.calculateTileURL(tileNumbers.x, tileNumbers.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            // Upload all images to online image-processor
                            let loadingResponces = try imageProcessor.uploadTwoTiles([baseUrl, overlayUrl], req)
                            
                            // Redirect to URL of resulting file in image-processor storage
                            return imageProcessor.syncTwo(loadingResponces, req) { res in
                                
                                let newUrl = imageProcessor.getUrlOverlay(baseUrl, overlayUrl)
                                return redirect(to: newUrl, with: req)
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
                let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, req)
                
                
                // Get URL of resulting file in image-processor storage
                let redirectingResponce = imageProcessor.syncFour(loadingResponces, req) { res in
                    
                    let processedImageUrl = imageProcessor.getUrlWithOffset(fourTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                    
                    return redirect(to: processedImageUrl, with: req)
                }
                
                return redirectingResponce
                
                
                
                
                
            case "wgs84_overlay":
                
                let coordinates = try coordinateTransformer.getCoordinates(xText, yText, zoom)
                
                let tilePosition = coordinateTransformer.getWGS84Position(coordinates.lat_deg, coordinates.lon_deg, withZoom: zoom)
                
                // Load layers info from data base in Future format
                let mapList = try sqlHandler.getOverlayBy(setName: mapName, req)
                
                // Synchronization Futrure to data object.
                // Generating redirect URL-response to processed image.
                let redirectingResponce = mapList.flatMap(to: Response.self) { mapListData  in
                    
                    // Load info for every layers from data base in Future format
                    let baseMapName = mapListData.baseName
                    let overlayMapName = mapListData.overlayName
                    let baseMapData = try sqlHandler.getBy(mapName: baseMapName, req)
                    let overlayMapData = try sqlHandler.getBy(mapName: overlayMapName, req)
                    
                    
                    // Synchronization Futrure to data object.
                    return baseMapData.flatMap(to: Response.self) { baseObject  in
                        return overlayMapData.flatMap(to: Response.self) { overObject  in
                            
                            // To make one image with offset I need four nearest to crop.
                            let fourTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, baseObject.backgroundUrl, baseObject.backgroundServerName)
                            
                            let fourOverTilesAroundUrls = urlPatchCreator.calculateFourTilesUrls(tilePosition.x, tilePosition.y, zoom, overObject.backgroundUrl, overObject.backgroundServerName)
                            
                            // Upload all images to online image-processor
                            let loadingResponces = try imageProcessor.uploadFourTiles(fourTilesAroundUrls, req)
                            
                            let loadingOverResponces = try imageProcessor.uploadFourTiles(fourOverTilesAroundUrls, req)
                            
                            // Get URL of resulting file in image-processor storage
                            return imageProcessor.syncFour(loadingResponces, req) { res1 in
                                return imageProcessor.syncFour(loadingOverResponces, req) { res2 in
                                    
                                    let processedImageUrl = imageProcessor.getUrlWithOffsetAndOverlay(fourTilesAroundUrls, fourOverTilesAroundUrls, tilePosition.offsetX, tilePosition.offsetY)
                                    
                                    return redirect(to: processedImageUrl, with: req)
                                }
                            }
                        }
                    }
                }
                
                return redirectingResponce
                
                
                
                
                
                
            case "checkAllMirrors":
                
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                let redirectingResponce = try checkMirrorsList(mapName, tileNumbers.x, tileNumbers.y, zoom, req)
                
                return redirectingResponce
                
                
                
                
                
                
            case "mapSet":
                
                let tileNumbers = try coordinateTransformer.calculateTileNumbers(xText, yText, zoom)
                
                // Load info for every layers from data base in Future format
                let layersList = try sqlHandler.getPriorityListBy(setName: mapName, zoom: zoom, req)
                
                // Synchronization Futrure to data object.
                let redirectingResponce = layersList.flatMap(to: Response.self) { layersListData  in
                    
                    guard layersListData.count != 0 else {return notFoundResponce(req)}
                    
                    // Start checking of file existing for all layers URLs
                    let startIndex = 0
                    
                    let firstExistingUrlResponse = try checkMapsetList(layersListData, startIndex, tileNumbers.x, tileNumbers.y, zoom, req)
                    
                    return firstExistingUrlResponse
                }
                return redirectingResponce
                
                
                
                
                
            default:
                return errorResponce("Unknown value MapMode in data base", req)
            }
            
        }
        
        return responce
        
    }
    
    
    
    

    
    
    
 
    
    
    // MARK: Recursive checkers for file existing by URL
    
    // Checker for MapSet mode
    func checkMapsetList(_ maps: [PriorityMapsList], _ index: Int, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        var redirectingResponse: Future<Response>
        
        let currentMapName = maps[index].mapName
    
        
        if maps[index].notChecking {
            redirectingResponse = try startSearchingForMap(currentMapName, xText: String(x), String(y), z, req)
            
        } else {
            // Start finding first url with existing file.
            // All testing maps must be in Mirrors database!
            let response = try checkMirrorsList(currentMapName, x, y, z, req)
            
            redirectingResponse = response.flatMap(to: Response.self) { res in
                
                if (res.http.status.code == 404) && (maps.count > index+1) {
                    // print("Recursive find next ")
                    return try checkMapsetList(maps, index+1, x, y, z, req)
                
                } else if(res.http.status.code == 404) {
                    // print("Fail ")
                    return notFoundResponce(req)
                
                } else {
                    // print("Success ")
                    return req.future(res)
                }
            }
        }
        
        return redirectingResponse
    }
    
    
    
    // Checker for Mirrors mode
    func checkMirrorsList(_ mirrorName: String, _ x: Int, _ y: Int, _ z: Int, _ req: Request) throws -> Future<Response> {
        
        // Load info for every mirrors from data base in Future format
        let mirrorsList = try sqlHandler.getMirrorsListBy(setName: mirrorName, req)
        
        // Synchronization Futrure to data object.
        let redirectingResponce = mirrorsList.flatMap(to: Response.self) { mirrorsListData  in
            
            guard mirrorsListData.count != 0 else {return notFoundResponce(req)}
            
            let urls = mirrorsListData.map {$0.url}
            let hosts = mirrorsListData.map {$0.host}
            let patchs = mirrorsListData.map {$0.patch}
            let ports = mirrorsListData.map {$0.port}
            
            var firstFoundedUrlResponse : Future<Response>
            
            // Custom randomized iterating of array
            let startIndex = 0
            let shuffledOrder = makeShuffledOrder(maxNumber: mirrorsListData.count)
            
            // File checker
            let firstCheckingIndex = shuffledOrder[startIndex] ?? 0
            
            
            if hosts[firstCheckingIndex] == "dont't need to check" {
                // Global maps. Dont't need to check it
                let newUrl = urlPatchCreator.calculateTileURL(x, y, z, urls[firstCheckingIndex], "")
                
                firstFoundedUrlResponse = redirect(to: newUrl, with: req)
                
            } else {
                // Local maps. Start checking of file existing for all mirrors URLs
                firstFoundedUrlResponse = findExistingMirrorNumber(index: startIndex, hosts, ports, patchs, urls, x, y, z, shuffledOrder, req: req)
            }
            
            return firstFoundedUrlResponse
        }
        
        return redirectingResponce
    }
    

    
    
    
    // Mirrors mode recursive checker sub function
    
    func findExistingMirrorNumber(index: Int, _ hosts: [String], _ ports: [String], _ patchs: [String], _ urls: [String], _ x: Int, _ y: Int, _ z: Int, _ order: [Int:Int], req: Request) -> Future<Response> {
        
        guard let currentShuffledIndex = order[index] else {return notFoundResponce(req)}
        
        let timeout = 350
        let defaultPort = 8080
        var connection: EventLoopFuture<HTTPClient>
        
        // Connect to Host URL with correct port
        if ports[currentShuffledIndex] == "any" {
            connection = HTTPClient.connect(hostname: hosts[currentShuffledIndex], on: req)
        } else {
            let portNumber = Int(ports[currentShuffledIndex]) ?? defaultPort
            connection = HTTPClient.connect(hostname: hosts[currentShuffledIndex], port: portNumber, connectTimeout: .milliseconds(timeout), on: req)
        }
        
        // Synchronization: Waiting, while coonection will be started
        let firstFoundedFileIndex = connection.flatMap { (client) -> Future<Response> in
            
            // Generate URL and make Request for it
            let currentUrl = urlPatchCreator.calculateTileURL(x, y, z, patchs[currentShuffledIndex], "")
            
            let request = HTTPRequest(method: .HEAD, url: currentUrl)
            
            
            // Send Request and check HTML status code
            // Return index of founded file if success.
            return client.send(request).flatMap{ (response) -> Future<Response> in
                
                if response.status.code != 404 {
                    //print ("Success: File founded! ", hosts[shuffledIndex], currentUrl)
                    let newUrl = urlPatchCreator.calculateTileURL(x, y, z, urls[currentShuffledIndex], "")
                    return redirect(to: newUrl, with: req)
                    
                } else if (index + 1) < hosts.count {
                    //print ("Recursive find for next index: ", hosts[shuffledIndex], currentUrl)
                    return findExistingMirrorNumber(index: index+1, hosts, ports, patchs, urls, x, y, z, order, req: req)
                    
                } else {
                    //print("Fail: All URLs checked and file not founded.")
                    return notFoundResponce(req)
                }
            }
        }
        
        return firstFoundedFileIndex
    }
    
 
 
}
