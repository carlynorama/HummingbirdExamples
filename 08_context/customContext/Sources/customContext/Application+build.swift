import Hummingbird
import Logging
import Mustache

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

//Set alias to custom RequestContext
typealias AppRequestContext = MyForwardingContext

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

//Decodable for testing. 
struct ContextInfo: ResponseEncodable, Decodable {
  let timeConsumingData: Int?
  let noteToPass: String?
  let maxUploadSize: Int
  let endpointPath: String?
  let parameters: String
  let request_id: String
}

func buildRouter() async throws -> Router<AppRequestContext> {
  let router = Router(context: AppRequestContext.self)

  router.addMiddleware {
    SendingMiddleware()
    LogRequestsMiddleware(.info)
    ReceivingMiddleware()
  }

  router.get("/ping") { _, _ -> HTTPResponse.Status in
    return .ok
  }

  router.get("contextSpy") { _, context -> ContextInfo in
    ContextInfo(
      timeConsumingData: context.timeConsumingData,
      noteToPass: context.noteToPass,
      maxUploadSize: context.maxUploadSize,
      endpointPath: context.endpointPath,
      parameters: "\(context.parameters)",
      request_id: context.id)
  }

  //http://localhost:8080/contextSpy/anythingHere
  //"parameters": ... elements: [(key: \"number\", value: \"anythingHere\")] ...
  router.get("contextSpy/{number}") { _, context -> ContextInfo in
    ContextInfo(
      timeConsumingData: context.timeConsumingData,
      noteToPass: context.noteToPass,
      maxUploadSize: context.maxUploadSize,
      endpointPath: context.endpointPath,
      parameters: "\(context.parameters)",
      request_id: context.id)
  }



  let subRoutes = router.group("kiddiePool", context: RCJunior.self) 
  subRoutes.get { _, context -> String in
        print("child route without \"number\"")
        return "CODE: \(context.magicNumber)"
    }
  subRoutes.get("{number}")  { _, context -> String in
        print("child route with \"number\"")
        return "CODE: \(context.magicNumber)"
    }

  return router
}
