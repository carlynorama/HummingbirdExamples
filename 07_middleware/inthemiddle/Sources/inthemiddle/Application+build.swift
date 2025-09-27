import Hummingbird
import Logging
import Mustache

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

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
  let mustacheLibrary = try await MustacheLibrary(directory: Bundle.module.resourcePath!)
  //let errorTemplate = mustacheLibrary.getTemplate(named: "error")!

  router.addMiddleware {
    //Mustache based error page.
    ErrorPageMiddleware(mustacheLibrary: mustacheLibrary)

    //built in logger.
    LogRequestsMiddleware(.info)

    //custom middleware for logging
    LogHeadersMiddleware(level: .info)
    LogErrorsMiddleware(level: .info)


    //These will supersede the Dynamic Error page because
    //it is no longer throwing an error.
    //Serves static 404 pages
    Static404Middleware()
    //Serves JSON error
    JSONErrorMiddleware()

    //serves the static files in public folder by default.
    FileMiddleware(searchForIndexHtml: true)
    // AlmostEmptyMiddleware(message: "buildRouter add")
  }

  router.get("/ping") { _, _ -> HTTPResponse.Status in
    return .ok
  }

  router.get("hello") { _, _ in
    return "HELLO"
  }

  return router
}
