import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let vaporController = VaporController()
    

    router.get("", String.parameter, String.parameter, String.parameter,Int.parameter, use: vaporController.startFindingTile)
    
    
    
//    вернуть таблицу с названием всех карт и их описанием
    router.get("list", use: vaporController.list)
    
//    Вернуть изображение по ссылке с указанным значение прозрачности
//    router.get("opacity", Double.parameter, String.parameter, use: controller.splitter)

//    Получить по ID
//    router.get("getbyid", use: vaporController.getById)
    
    

    
    
    // TODO: Перенести в какое-нибудь специальное место
    
    let instructionText = """
Welcome to AnyGIS API

This is a utility to connect different navigation applications (web, ios, android)
to map sources with non-standard URLS. It allows you to convert coordinates.
Also it can process tile images.



You can load tile by following to URL with name:
thisSiteName / MapName / xTileNumber / yTileNumber / zoomLevel

For example let's load a Wikimapia tile:

thisSiteName    = https://anygis.herokuapp.com/
MapName         = Wikimapia
xTileNumber     = 549
yTileNumber     = 297
zoomLevel       = 10

Result URL to load this tile will looking like this:
https://anygis.herokuapp.com/Wikimapia/549/297/10

(P.S: Here we uses standart WebMercator tile numbers. Like in OSM or Google maps)



You can also find tile by coordinates:
thisSiteName / MapName / longitude / latitude / zoomLevel
https://anygis.herokuapp.com/Wikimapia/56.062293/37.708244/10



To get full list of maps sources follow this:
https://anygis.herokuapp.com/list




(nnngrach@gmail.com)
(2018)
"""
    
    
    
    router.get { req in
        //return "Welcome to AnyGIS!"
        return instructionText
    }
    
    
  
    
}


