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
    // Start checker for cashe storage. And clean it if needed.
    // Launched by Uptimerobot.com
    router.get("new_day_status_update") { req -> String in
        try cloudinaryHandler.newDayStatusUpdate(req)
        
        //try casheHandler.erase(req)
        return "Success: Cloudinary cashe is empty"
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
    
    
    
    
    router.get("experiments_playground") { req -> String in

        let handler = CloudinaryAccountsHandler()
        //return try handler.writeToDB(title: "test", jsonData: "32dfgg1", req)
        //return try handler.readAllFromDB(title: "test", req)
        //return try handler.readLastFromDB(title: "test", req)
        //try handler.newDayStatusUpdate(req)
        
 
        
//        let testJson = """
//{"plan":"Free","last_updated":"2019-04-26","transformations":{"usage":4588,"credits_usage":4.59},"objects":{"usage":4620},"bandwidth":{"usage":12412231,"credits_usage":0.01},"storage":{"usage":139172203,"credits_usage":0.13},"credits":{"usage":4.73,"limit":25.0,"used_percent":18.92},"requests":1483,"resources":3446,"derived_resources":1174,"media_limits":{"image_max_size_bytes":10485760,"video_max_size_bytes":104857600,"raw_max_size_bytes":10485760,"image_max_px":25000000,"asset_max_total_px":50000000}}
//"""
//
//        let decoded = try JSONDecoder().decode(CloudinaryUsage.self, from: testJson)
//        print(decoded)
        
        return "Hello, world!"
    }

}
