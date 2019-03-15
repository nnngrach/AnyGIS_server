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
    router.get("cashe_eraser") { req -> String in
        try casheHandler.erase(req)
        return "Success: Cloudinary cashe is empty"
    }
    
    
    
    // MARK: Script to generate XML and MD files in git repo on local maschine.
    router.get("update_local_files") { req -> String in
        #if os(Linux)
            return "Files generation works only on local maschine"
        #else
            let diskHandler = DiskHandler()
            let templates = TextTemplates()
            let guruMapsGenerator = GuruMapsGenerator()
            let locusMapsGenerator = LocusMapsGenerator()
            let markdownPagesGenerator = MarkdownPagesGenerator()
            let locusInstallersGenerator = LocusInstallersGenerator()
        
        
            diskHandler.cleanFolder(patch: templates.localPathToInstallers)
            diskHandler.cleanFolder(patch: templates.localPathToMarkdownPages)
            diskHandler.cleanXmlFromFolder(patch: templates.localPathToLocusMapsFull)
            diskHandler.cleanXmlFromFolder(patch: templates.localPathToLocusMapsShort)
            diskHandler.cleanFolder(patch: templates.localPathToGuruMapsFull)
            diskHandler.cleanFolder(patch: templates.localPathToGuruMapsShort)
        
            locusInstallersGenerator.createSingleMapsLoader(req)
            locusInstallersGenerator.createFolderLoader(req)
            locusInstallersGenerator.createAllMapsLoader(isShortSet: true, req)
            locusInstallersGenerator.createAllMapsLoader(isShortSet: false, req)

            markdownPagesGenerator.createMarkdownPage(forLocus: true, forIOS: false, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(forLocus: true, forIOS: false, isShortSet: false, req)
            markdownPagesGenerator.createMarkdownPage(forLocus: false, forIOS: false, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(forLocus: false, forIOS: false, isShortSet: false, req)
            markdownPagesGenerator.createMarkdownPage(forLocus: false, forIOS: true, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(forLocus: false, forIOS: true, isShortSet: false, req)

            guruMapsGenerator.createAll(isShortSet: true, req)
            guruMapsGenerator.createAll(isShortSet: false, req)
            locusMapsGenerator.createAll(isShortSet: true, req)
            locusMapsGenerator.createAll(isShortSet: false, req)
        
            return "Files generation finished!"
        #endif
    }
    
    
    // To force download file (don't open)
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
    
    
    

    
    
    router.get("experiments_playground") { req -> Future<Response> in
        
        let loginURL = "http://backend.navionics.io/tile/get_key/Navionics_internalpurpose_00001/webapp.navionics.com?_=" + String(NSDate().timeIntervalSince1970)
        
        print(Int(NSDate().timeIntervalSince1970))
  
        let headers: HTTPHeaders = ["Origin": "http://webapp.navionics.com", "Referer": "http://webapp.navionics.com/"]
        
        let baseURL = "http://backend.navionics.io/tile/10/583/296?LAYERS=config_1_10.00_0&TRANSPARENT=FALSE&UGC=FALSE&navtoken="
        
        let asnswerForCode = try req
            .client()
            .get(loginURL, headers: headers)
            .flatMap(to: Response.self) { answerData in
                let code = "\(answerData.http.body)"
                let fullURL = baseURL+code
                let res = try req.client().get(fullURL, headers: headers)
                
                return res
            }
        
        return asnswerForCode
    }
    
}
