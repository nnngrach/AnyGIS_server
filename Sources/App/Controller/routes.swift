import Vapor
import FluentSQLite



/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let webHandler = WebHandler()
    let sqlHandler = SQLHandler()
    let casheHandler = CloudinaryCasheHandler()
    let cloudinaryHandler = CloudinaryAccountsHandler()
    
    
    
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
    
    
    
    
    
    // MARK: Main request to get tile image
    router.get(String.parameter, String.parameter, String.parameter,Int.parameter) { request -> Future<Response> in
        
        // Extracting values from URL parameters
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        let httpResponse =  try webHandler.startSearchingForMap(mapName, xText: xText, yText, zoom, request)
        
        return httpResponse
    }
    
    
    
    
    // MARK: Storage functions
    // Launched by Uptimerobot.com
    // Start checker for cashe storage. And clean it if needed.
    // Deactivate unworking accounts.
    router.get("new_day_status_update") { req -> String in
        try cloudinaryHandler.newDayStatusUpdate(req)
        return "Success!"
    }
    
    
    
    router.get("active_accounts") { req -> Future<[String]> in
        return try sqlHandler.getServiceDataBy(serviceName: "CloudinaryWorkedAccountsList", req)
            .map { record -> [String] in
                
                var accounts = record[0].apiSecret.components(separatedBy: ";")
                accounts.removeLast()
                let sortedList = accounts.sorted(by: { s1, s2 in return Int(s1)! < Int(s2)! })
                return sortedList
        }
    }

    
    
    // To force download file (don't open as text)
    router.get("download", String.parameter, String.parameter) { req -> Future<Response> in
        
        // Extracting values from URL parameters
        let folder = try req.parameters.next(String.self)
        let filename = try req.parameters.next(String.self)

        let url = "https://anygis.herokuapp.com/" + folder + "/" + filename

        let futureContent = try req.client().get(url)


        let response = futureContent.flatMap(to: Response.self) { content in

            let headers: HTTPHeaders = ["content-disposition": "attachment; filename=\"\(filename)\""]
            
            let res = HTTPResponse(headers: headers, body: content.http.body)
            
            return req.future(Response(http: res, using: req))
        }

        return response
    }
    
    
    
    
//    router.get("experiments_playground") { req -> String in
//        return "Hello, world!"
//    }

}
