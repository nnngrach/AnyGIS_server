import Vapor
import FluentSQLite




/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let webHandler = WebHandler()
    let sqlHandler = SQLHandler()
    let casheHandler = CloudinaryCasheHandler()
    let cloudinaryHandler = CloudinaryAccountsHandler()
    let previewHandler = PreviewHandler()
    let mapTester = MapTester()
    
    

    // Show welcome "index" page.
    // Here I'm using "Leaf" Html-page generator.
    // Patch:  ...\Resources\Views\*.leaf
    router.get("api") { req -> Future<View> in
        return try req.view().render("home")
    }
    
    // Show html table with list of all maps
    router.get("api", "v1", "list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchAllMapsList(req)
        return try req.view().render("tableMaps", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with list of mirrors for some maps
    router.get("api", "v1", "mirrors_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchMirrorsMapsList(req)
        return try req.view().render("tableMirrors", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with layers for overlay maps
    router.get("api", "v1", "overlay_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchOverlayMapsList(req)
        return try req.view().render("tableOverlay", ["databaseMaps": databaseMaps])
    }
    
    // Show html table with layers for "Combo-mode" maps
    router.get("api", "v1", "priority_list") { req -> Future<View> in
        let databaseMaps = sqlHandler.fetchPriorityMapsList(req)
        return try req.view().render("tablePriority", ["databaseMaps": databaseMaps])
    }
    
    
    
    // Ping all testing maps from database
    router.get("api", "v1", "test") { req -> Future<Response> in
        return mapTester.testAllMaps(req: req)
    }
    
  
    // Preview my maps with Nakarte.me
    router.get("api", "v1", "preview", String.parameter) { req -> Future<Response> in
        
        let mapName = try req.parameters.next(String.self)
        
        do {
            
            let url = try previewHandler.generateLinkFor(mapName: mapName, req: req)
            
            return url.map { urlText in
                return req.redirect(to: urlText)
            }
            
        } catch {
            print("catch")
            return req.future(error: GlobalErrors.parsingFail)
        }
    }
 
    
    
    
    // MARK: Main request to get tile image
    router.get("api", "v1", String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        // Extracting values from URL parameters
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        let httpResponse =  try webHandler.startSearchingForMap(mapName, xText: xText, yText, zoom, request)
        
        return httpResponse
    }
    

    
    
  
    // Redirect to one of Mapshoter Api mirrors
    router.get("api", "v1", "mapshooter", String.parameter, Int.parameter, Int.parameter, Int.parameter, Int.parameter) { request -> Response in
        
        // Extracting values from URL parameters
        let mode = try request.parameters.next(String.self)
        let x = try request.parameters.next(Int.self)
        let y = try request.parameters.next(Int.self)
        let z = try request.parameters.next(Int.self)
        let crossZ = try request.parameters.next(Int.self)
        
        guard let script = request.query[String.self, at: "script"] else {
            throw Abort(.badRequest)
        }
        
        //let serverNames = ["a", "b"]
        //let randomValue = randomNubmerForHeroku(serverNames.count)
        //let serverName = serverNames[randomValue]
        
        let mirrorUrl = "http://68.183.65.138:5500\(mode)/\(x)/\(y)/\(z)/\(crossZ)?script=\(script)"
        
        return request.redirect(to: mirrorUrl)
    }

    
    
    
    // To force download file (don't open as text)
    router.get("api", "v1", "download", String.parameter, String.parameter) { req -> Future<Response> in
        
        // Extracting values from URL parameters
        let folder = try req.parameters.next(String.self)
        let filename = try req.parameters.next(String.self)

        let url = SITE_HOST + "/server/" + folder + "/" + filename
        

        let futureContent = try req.client().get(url)


        let response = futureContent.flatMap(to: Response.self) { content in

            let headers: HTTPHeaders = ["content-disposition": "attachment; filename=\"\(filename)\""]
            
            let res = HTTPResponse(headers: headers, body: content.http.body)
            
            return req.future(Response(http: res, using: req))
        }

        return response
    }
    
    
    
    

    
//    router.get("api", "v1", "experiments_playground") { req -> String in
//
//        try req.client()
//        //.get("http://ingreelab.net/A52CEA6D090B666F0A2C6A85A53832F128B6CAED/15/17920/10763.png")
//        //.get("http://ingreelab.net/A52CEA6D090B666F0A2C6A85A53832F128B6CAED/18/167482/78211.png")
//        .get("http://ingreelab.net/A52CEA6D090B666F0A2C6A85A53832F128B6CAED/14/10470/4888.png")
//            
//            .map { res in
//                print(res.http.body.count)
//        }
//        return "Hello, world!"
//    }


}
