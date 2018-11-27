import Vapor
import Foundation
import Fluent
import FluentSQLite

final class VaporController {
    
    let controller = IndependentController()

    
    
    func startFindingTile(_ request: Request) throws -> Future<Response> {
        
        let mapName = try request.parameters.next(String.self)
        let xText = try request.parameters.next(String.self)
        let yText = try request.parameters.next(String.self)
        let zoom = try request.parameters.next(Int.self)
        
        let mapInfoJSON = MapData.query(on: request)
            .filter(\MapData.name == mapName)
            .first()
            .unwrap(or: Abort.init(
                HTTPResponseStatus.custom(code: 501, reasonPhrase: "Unknown map name")))
        
        
        
        let responce = mapInfoJSON.map(to: Response.self) { mapInfoObject in
           
            let outputData = self.controller.findTile(mapName, xText, yText, zoom, mapInfoObject)
        
            
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
                //throw desctiption
                return request.response(http: HTTPResponse(status: .custom(code: 501, reasonPhrase: desctiption), body: ""))
                
                
            /*
            default:
                return request.response(http: HTTPResponse(status: .custom(code: 500, reasonPhrase: "My custom error"), body: ""))
            */
                
            }

        }
        
        return responce
    }
    
    
    
    
    
//    func list(_ req: Request) throws -> String {
//        return "This function will cooming soon..."
//    }
    
    
    
    
    /*
    func getById(_ request: Request) throws -> Future<MapData> {
        let objectId = 5
        return MapData.find(objectId, on: request).map(to: MapData.self) { post in
            guard let post = post else { throw Abort.init(HTTPStatus.notFound) }
            return post
        }
    }
    */
    
  
    
}


