import Hummingbird
import Logging


#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Mustache

//There is one main Context type per router. In case this needs to change in the
//future its handy to set the type as an alias so won't need to update all the
//child-type references
typealias AppRequestContext = BasicRequestContext

public func buildApplication(_ arguments: some AppArguments) async throws
    -> some ApplicationProtocol
{
    let environment = Environment()

    let logger = {
        var logger = Logger(label: arguments.nameTag)
        logger.logLevel =
            arguments.logLevel ?? environment.get("LOG_LEVEL").flatMap {
                Logger.Level(rawValue: $0)
            } ?? .info
        return logger
    }()

    let router = try await buildRouter()

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

func buildRouter() async throws -> Router<AppRequestContext> {
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

    router.get("organ/:message") { _, context in
        guard let message = context.parameters.get("message", as: String.self) else {
            throw HTTPError(.badRequest)
        }
        return OrganPlayerHTML(message)
    }

    let mustacheLibrary = try await MustacheLibrary(directory: Bundle.module.resourcePath!)
    //let mustacheLibrary = MustacheLibrary()

    router.get("/acrobat") { _, _ in "not here"}
    router.get("acrobat/:message") { _, context in
        guard let message = context.parameters.get("message", as: String.self) else {
            throw HTTPError(.badRequest)
        }
        let decoded = message.removingPercentEncoding ?? "can't-balance-here"
        return AcrobatHTML(decoded, library: mustacheLibrary)
    }

    return router
}
