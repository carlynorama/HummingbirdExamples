import Hummingbird
import Logging

import OpenAPIHummingbird
import OpenAPIRuntime
import ClownAPI

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable. 
/// Any variables added here also have to be added to `App` in App.swift and 
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var nameTag:String { get }
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
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
    let router = try buildRouter()
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

/// Build router
func buildRouter() throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
        // store request context in TaskLocal
        OpenAPIRequestContextMiddleware()
    }
    
    router.get("/ping") { _, _ -> HTTPResponse.Status in
        return .ok
    }

    let repository = ClownCar()
    let clown_api = ClownAPIHandler(repository: repository)
    do {
        print(try Servers.Server1.url())
        let url = try Servers.Server1.url()

        try clown_api.registerHandlers(on: router, serverURL: url) 

    } catch {
        //handle this situation. 
        
        print("hello api failed to register. Those endpoints will not be available.")
    }

    return router
}
