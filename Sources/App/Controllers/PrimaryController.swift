import Vapor
import Foundation

final class PrimaryController {
    
    let coordinateTransformer = CoordinateTransformer()
    
    
    func list(_ req: Request) throws -> String {
        return "This function will cooming soon..."
    }
    
    
    
    func convertAndStartSplitter(_ req: Request) throws -> Response {
        
        let name = try req.parameters.next(String.self)
        let xText = try req.parameters.next(String.self)
        let yText = try req.parameters.next(String.self)
        let z = try req.parameters.next(Int.self)
        
        
        let tileNumbers = try coordinateTransformer.normalizeCoordinates(xText, yText, z)
        
    
        
        // Запросить строку из базы по имении
        
        // Запустить требуемый режим по имени
        
        // Вернуть результат (редирект или картинка)
        
        
        
        
        
        
        //return req.redirect(to: "http://google.ru")
        //let response: Response = req.makeResponse("hello any gis")
        let paramInText = experinemtingText(x: tileNumbers.x, y: tileNumbers.y, z: z)
        let response: Response = req.makeResponse(name + paramInText)
        return response
    }
    
    
    
    
    func experinemtingText (x: Int, y: Int, z: Int) -> String {
        return " \(x) \(y) \(z)"
    }
    
    
    
    
 
    
    
    
    
    
// ====================================================
// EXPERIMENTING AREA
    
    
    /*
    func redirect(_ req: Request) throws -> Future<Response> {
        return Future.map(on: req) { return req.redirect(to: "http://google.ru") }
    }
    
    
    
    
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
 */
    
}
