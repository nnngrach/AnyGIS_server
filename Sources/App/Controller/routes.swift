import Foundation
import Vapor

 

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let webHandler = WebHandler()
    let sqlHandler = SQLHandler()
    let casheHandler = CasheHandler()
    
    
    
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
    
    
    
    
    
    // MARK: Storage functions
    // Start checker for cashe storage. And clean it if needed.
    // Launched by Uptimerobot.com
    router.get("cashe_eraser") { req -> String in
        try casheHandler.erase(req)
        return "Success: Cloudinary cashe is empty"
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
    
    
    
    
    
    
//Future<Response>
     router.get("experiments_playground") { req -> Future<Response> in
        let a = try req.client().get("https://anygis.herokuapp.com/custom-map-source/galileo-bing-maps.ms")
        
        let b = a.flatMap(to: Response.self) { c in
            
            var headers1 = c.http.headers
            
            let newHeader = HTTPHeaders([("Content-Type","application/octet-stream") ,
                                        ("Content-Disposition","attachment"),
                                        ("filename","test.ms")])
            
            let e = c.http.contentType
            
            
           
            let d = Response(http: HTTPResponse(status: c.http.status,
                                                version: c.http.version,
                                                headers: newHeader,
                                                body: c.http.body),
                             using: req)
            
            
            
            //let file = File(data: c.http.body as! LosslessDataConvertible, filename: "tetest")
            
            let name = "tetetest.ms"
            let headers: HTTPHeaders = ["content-disposition": "attachment; filename=\"\(name)\""]
            
            let res = HTTPResponse(headers: headers, body: c.http.body)
            
            return req.future(Response(http: res, using: req))
        }
        
        return b
     }
    
    
//    func download(_ req: Request) throws -> Future<Response> {
//        return try req.parameters.next(Model.self).map { obj in
//            let file = File(data: obj.data, filename: obj.filename)
//            return req.response(file: file)
//        }
//    }


  
    
}
