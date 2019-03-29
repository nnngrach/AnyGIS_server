import Vapor
import FluentSQLite


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
            let oruxMapsGenerator = OruxMapsGenerator()
            let locusMapsGenerator = LocusMapsGenerator()
            let osmandMapsGenerator = OsmandMapGenerator()
            let markdownPagesGenerator = MarkdownPagesGenerator()
            let locusInstallersGenerator = LocusInstallersGenerator()
        
            diskHandler.cleanFolder(patch: templates.localPathToInstallers)
            diskHandler.cleanFolder(patch: templates.localPathToMarkdownPages)
            diskHandler.cleanXmlFromFolder(patch: templates.localPathToLocusMapsFull)
            diskHandler.cleanXmlFromFolder(patch: templates.localPathToLocusMapsShort)
            diskHandler.cleanFolder(patch: templates.localPathToGuruMapsFull)
            diskHandler.cleanFolder(patch: templates.localPathToGuruMapsShort)
            diskHandler.cleanFolder(patch: templates.localPathToGuruMapsInServer)
            diskHandler.cleanFolder(patch: templates.localPathToOsmandMapsFull)
            diskHandler.cleanFolder(patch: templates.localPathToOsmandMapsShort)
            diskHandler.cleanFolder(patch: templates.localPathToOruxMapsFullInServer)
            diskHandler.cleanFolder(patch: templates.localPathToOruxMapsShortInServer)
        
            locusInstallersGenerator.createSingleMapsLoader(req)
            locusInstallersGenerator.createFolderLoader(req)
            locusInstallersGenerator.createAllMapsLoader(isShortSet: true, req)
            locusInstallersGenerator.createAllMapsLoader(isShortSet: false, req)

            markdownPagesGenerator.createMarkdownPage(appName: .Locus, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(appName: .Locus, isShortSet: false, req)
            markdownPagesGenerator.createMarkdownPage(appName: .GuruMapsAndroid, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(appName: .GuruMapsAndroid, isShortSet: false, req)
            markdownPagesGenerator.createMarkdownPage(appName: .GuruMapsIOS, isShortSet: true, req)
            markdownPagesGenerator.createMarkdownPage(appName: .GuruMapsIOS, isShortSet: false, req)

            guruMapsGenerator.createAll(isShortSet: true, req)
            guruMapsGenerator.createAll(isShortSet: false, req)
            oruxMapsGenerator.createAll(isShortSet: true, req)
            oruxMapsGenerator.createAll(isShortSet: false, req)
            locusMapsGenerator.createAll(isShortSet: true, req)
            locusMapsGenerator.createAll(isShortSet: false, req)
            osmandMapsGenerator.createAll(isShortSet: true, req)
            osmandMapsGenerator.createAll(isShortSet: false, req)

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
    
    
    
    
    
    
    
//    router.get("experiments_playground1") { req -> String in
//
////        let text = "http://maps.marshruty.ru/ml.ashx?al=1&i=1&x={1}&y={2}&z={0}"
//        //let text = "http://anygis.herokuapp.com/Osm_Sputnik/{1}/{2}/{0}"
//        let text = "http://anygis.herokuapp.com/Google_Sat_RU_SD/{1}/{2}/{0}"
//
//        let dataText = text.data(using: .utf8)!
//
//
//
//        req.withPooledConnection(to: .sqliteOsmand) { (conn: SQLiteConnection) -> Future<Void> in
//
//
//
//            conn.update(Tetest.self)
//                .set(\Tetest.url, to: text)
////                .where(\Tetest.expireminutes == "0")
//                .run()
//
//
//            return req.future()
//        }
//
//        return "Hello, world1"
//    }
    
    
    
    
  

//    router.get("experiments_playground") { req -> String in
//        
//        //            conn.update(info.self)
//        //                .set(\info.expireminutes == "123")
//        //                .where(\info.expireminutes == "0")
//        //                .run()
//        
//        let b = req.withPooledConnection(to: .sqliteOsmand) { (conn: SQLiteConnection) -> Future<Void> in
//            let users = conn.select()
//                .all().from(Tetest.self)
//                //.where(\Tetest.expireminutes == "0")
//                .all(decoding: Tetest.self)
//            //print(users) // Future<[User]>
//            
//            users.map { a in
//                print(a)
//            }
//            
//            return req.future()
//        }
//
//        return "Hello, world!"
//    }
    
    
    
    
//    router.get("sql") { req in
//        return req.withPooledConnection(to: .sqliteOsmand) { (conn: SQLiteConnection) in
//            return conn.select()
//                .column("sqlite_version")
//                .all(decoding: SQLiteVersion.self)
//            }.map { rows in
//                return rows[0].version
//        }
//    }
    
    
    
    
    
    
 
    router.get("experiments_playground") { req -> String in
        
        android_metadata.query(on: req).first().map { record in
            record?.delete(on: req)
        }
        
        let metaData = android_metadata(locale: "ru_RU")
        metaData.save(on: req)
        
        
        info.query(on: req).first().map { record in
            record?.delete(on: req)
        }
        
        
        
//        let infoData = info(minzoom: "-3",
//                            maxzoom: "16",
//                            url: "http://maps.marshruty.ru/ml.ashx?al=1&i=1&x={1}&y={2}&z={0}",
//                            tilenumbering: "BigPlanet",
//                            timecolumn: "no",
//                            expireminutes: "0",
//                            ellipsoid: 0)
        

        
//        let infoData = info(minzoom: "-3",
//                            maxzoom: "16",
//                            url: "http://anygis.herokuapp.com/Osm_Outdoors/{1}/{2}/{0}",
//                            tilenumbering: "BigPlanet",
//                            timecolumn: "no",
//                            expireminutes: "0",
//                            ellipsoid: 0)
        
//        let infoData = info(minzoom: "-3",
//                            maxzoom: "16",
//                            url: "http://anygis.herokuapp.com/Yandex_sat_clean_WGS84/{1}/{2}/{0}",
//                            tilenumbering: "BigPlanet",
//                            timecolumn: "no",
//                            expireminutes: "0",
//                            ellipsoid: 1)
        
        let infoData = info(minzoom: "-3",
                            maxzoom: "16",
                            url: "http://ecn.dynamic.t0.tiles.virtualearth.net/comp/ch/{3}?mkt=en-us&it=G,VE,BX,L,LA&shading=hill&og=2&n=z",
                            tilenumbering: "BigPlanet",
                            timecolumn: "no",
                            expireminutes: "0",
                            ellipsoid: 0)
        
        infoData.save(on: req)
        
        return "Hello, world!"
    }
  
    
    
 
    
    
//    router.get("experiments_playground") { req -> String in
//        return "Hello, world!"
//    }

}
