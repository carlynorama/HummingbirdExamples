import Hummingbird
import Logging


//There is one main Context type per router. In case this needs to change in the
//future its handy to set the type as an alias so won't need to update all the 
//child-type references 
typealias AppRequestContext = BasicRequestContext

public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()

    let logger = {
        var logger = Logger(label: arguments.nameTag)
        logger.logLevel = 
            arguments.logLevel ??
            environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()

    let router = buildRouter()

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

func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
        //serves the static files in public folder by default. 
        FileMiddleware(searchForIndexHtml: true)
    }

    // SIMPLE ROUTING

    // These three types have been given ResponseGenerator status by Hummingbird
    // - HTTPResponseStatus
    // - String
    // - Optional

    // The closure takes in a request and a context and returns 
    // some ResponseGenerator

    router.get("/ping") { _, _ -> HTTPResponse.Status in
        return .ok
    }

    router.get("/hello") { request, _ -> String in
        return "Well Hello!\n\n\(request)"
    }

    // full call
    router.on("/goodbye", method: .get) { request, context in
        return "Ciao!"
    }

    
  
    struct MiniCodable:Decodable, ResponseEncodable {
        let number: Int
        let phrase: String?
    }

    //the default encoder is JSON
    router.get("/encodable") { _, _ -> MiniCodable in
        return MiniCodable(number: 5, phrase: "hello!")
    }

    //---- WILDCARDS
    // https://docs.hummingbird.codes/2.0/documentation/hummingbird/routerguide#Wildcards
    router.get("/files/*") { request, _ in
        return request.uri.description
    }

    //note: ** is 1 or more, not zero or more. (2025/08) 
    router.get("/doublewild/**") { _, context in
        return context.parameters.getCatchAll().joined(separator: "/")
    }

    //---- Parameter Capture

    // //https://docs.hummingbird.codes/2.0/documentation/hummingbird/routerguide#Parameter-Capture
    router.get("/user/:id") { _, context in
        guard let id = context.parameters.get("id", as: Int.self) else {
            throw HTTPError(.badRequest)
        }
        return "\(id)"
    }

    router.get("/user/:id/:name") { _, context in
        guard let id = context.parameters.get("id", as: Int.self) else {
            throw HTTPError(.badRequest)
        }
        guard let name = context.parameters.get("name", as: String.self) else {
            throw HTTPError(.badRequest)
        }
        return "found \(name) for \(id)"
    }

    router.get("/img/{image}.jpg") { _, context in
        guard let imageName = context.parameters.get("image") else { 
            throw HTTPError(.badRequest)
        }
        switch imageName {
            case "bunny":
                return " \\\n  \\ /\\\n  ( )\n.( o )."
                //    \
                //     \ /\
                //     ( )
                //   .( o ). 
            default: return  "this is a \(imageName) "
        }
    }

    router.get("/query") { request, _ in
        // extract parameter from URL of form /query?id={userId}&name={message}}
        guard let id = request.uri.queryParameters.get("id", as: Double.self) else { 
            throw HTTPError(.badRequest) 
        }
        guard let message = request.uri.queryParameters.get("message", as: String.self) else { 
            throw HTTPError(.badRequest) 
        }
        return "tell \(id) I said \"\(message)\""
    }



    // GROUPS

    //if one has a logical group one can batch them together.
    router.group("/circus")
        .get(use: {_, _ in "if I had a list of circus acts I would show a list of circus acts"})
        
        .get("peanuts") { _, _ in "yummy peanuts"}
        .group("clowns")
            .get { _, _ in "if I had a list of clowns I would show a list of clowns"}
            .get("{id}", use: {_, context in "that's the clown called \(context.parameters.get("id") ?? "no ID")!"})


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

    router.group("/decodable")
        .get { _, _ in "this was a GET. Please submit some info using POST"}
        
        //curl -i -X POST localhost:8080/decodable/default -d'{"number":12,"phrase":"are you going to go my way"}'
        .post("default") { request, context in
            let decoded = try await request.decode(as: MiniCodable.self, context: context)
            print("DECODED DEFAULT: \(decoded.number) \(decoded.phrase ?? "")")
            return decoded //also consider an HTTPResponseStatus
        }
        .post("form") { request, context in
            print(request.headers)
            let decoded = try await URLEncodedFormDecoder().decode(MiniCodable.self, from: request, context: context)
            print("DECODED FORM: \(decoded)")
            return decoded
    }
        

    return router
}