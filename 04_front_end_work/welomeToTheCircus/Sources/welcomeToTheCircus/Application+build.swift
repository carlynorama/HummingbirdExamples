import Hummingbird
import Logging


//There is one main Context type per router. In case this needs to change in the
//future its handy to set the type as an alias so won't need to update all the 
//child-type references 
typealias AppRequestContext = BasicRequestContext

public func buildApplication(_ arguments: some AppArguments, clownStore:ClownController) async throws -> some ApplicationProtocol {
    let environment = Environment()

    let logger = {
        var logger = Logger(label: arguments.nameTag)
        logger.logLevel = 
            arguments.logLevel ??
            environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()

    let router = buildRouter(clownStore: clownStore)

    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: arguments.nameTag
        ),
        logger: logger
    )

    return app

}

func buildRouter(clownStore:ClownController) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
        //serves the static files in public folder by default. 
        FileMiddleware(searchForIndexHtml: true)
    }

    router.get("/ping") { _, _ -> HTTPResponse.Status in
        return .ok
    }

    //router.get(use: {_, _ in "if I had a list of circus acts I would show a list of circus acts"})
        
    router.get("peanuts") { _, _ in "yummy peanuts"}
    router.addRoutes(clownStore.endpoints, atPath: "clowns")
    
    router.get("announcement/:message") { _, context in
        guard let message = context.parameters.get("message", as: String.self) else {
            throw HTTPError(.badRequest)
        }
        return AnnouncementHTML(message)
    }

    // Child COntext

    // router.group("/decodable", context:FlexContext.self)
    //     .get { _, _ in "this was a GET. Please submit some info using POST"}
    //     //curl -i -X POST localhost:8080/decodable -d'{"number":12,"phrase":"are you going to go my way"}'
    //     .post { request, context -> HTTPResponse.Status in
    //         print(request.headers)
    //         let decoded = try await request.decode(as: MiniCodable.self, context: context)
    //         print("DECODED: \(decoded)")
    //         return .ok
    // }

    // router.group("/decodable")
    //     .get { _, _ in "this was a GET. Please submit some info using POST"}
        
    //     //curl -i -X POST localhost:8080/decodable/default -d'{"number":12,"phrase":"are you going to go my way"}'
    //     .post("default") { request, context in
    //         let decoded = try await request.decode(as: MiniCodable.self, context: context)
    //         print("DECODED DEFAULT: \(decoded.number) \(decoded.phrase ?? "")")
    //         return decoded //also consider an HTTPResponseStatus
    //     }
    //     .post("form") { request, context in
    //         print(request.headers)
    //         let decoded = try await URLEncodedFormDecoder().decode(MiniCodable.self, from: request, context: context)
    //         print("DECODED FORM: \(decoded)")
    //         return decoded
    // }
        

    return router
}