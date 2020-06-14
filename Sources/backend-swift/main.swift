import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectSQLite
import PerfectCRUD

// MARK: - Init Server
let server = HTTPServer()
server.serverPort = 8181

// MARK: - Routes
var routes = Routes()
routes.add(method: .get, uri: "/", handler: barra)
routes.add(method: .get, uri: "/missao", handler: missao)
routes.add(method: .get, uri: "/init", handler: initDB)
routes.add(method: .post, uri: "/missao", handler: missaoPost)

//routes.add(Missao.routesReactAdmin())

server.addRoutes(routes)

// MARK: - Handler
func barra(request: HTTPRequest, response: HTTPResponse) {
    response.sendJSON(RetornoSimple(message: "Hello, world!"), status: .ok)
}

func initDB(request: HTTPRequest, response: HTTPResponse) {
    resetDB()
    Missao.create()
    response.sendJSON(RetornoSimple(message: "Hello, world!"), status: .ok)
}

func missao(request: HTTPRequest, response: HTTPResponse) {
    do {
        let select = try Missao.select()
        try response
            .setBody(json: RetornoObject<[Missao]>(message: "ok", token: "token", object: select))
            .completed(status: .ok)
    } catch {
        Log("\(error)")
        response.sendJSON(RetornoSimple(message: "\(error)"), status: .internalServerError)
    }
}

func missaoPost(request: HTTPRequest, response: HTTPResponse) {
    guard let record = request.postObject(Missao.self) else {
        response.completed(status: .internalServerError)
        return
    }
    
    let (object, error) = Missao.create(request: request, response: response, record: record)
    
    do {
        if let object = object {
            try response
                .setBody(json: RetornoObject<Missao>(message: error?.localizedDescription ?? "ok", token: "token", object: object))
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } else {
            response.completed(status: .internalServerError)
        }
    } catch {
        Log(error.localizedDescription)
        response.completed(status: .internalServerError)
    }
}

// MARK: - Start server
do {
    Log("[INFO] Starting HTTP server on \(server.serverAddress):\(server.serverPort)")
    try server.start()
} catch {
    Log("Network error thrown: \(error.localizedDescription)")
}

public func Log(_ format: String) {
    NSLog(format)
}
