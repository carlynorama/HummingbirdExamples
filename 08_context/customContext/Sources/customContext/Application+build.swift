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
  let decoder:String
  let encoder:String
  let logger:String
}


func buildRouter() async throws -> Router<AppRequestContext> {
  let router = Router(context: AppRequestContext.self)

  router.addMiddleware {
    AlmostEmptyMiddleware(message: "top of middleware")
    SendingMiddleware()
    LogRequestsMiddleware(.info)
    ReceivingMiddleware()
    AlmostEmptyMiddleware(message: "bottom of middleware")
  }

  //curl -i "http://localhost:8080/ping/"
  router.get("/ping") { _, _ -> HTTPResponse.Status in
    return .ok
  }

  //curl -i "http://localhost:8080/contextSpy/"
  router.get("contextSpy") { _, context -> ContextInfo in
    ContextInfo(
      timeConsumingData: context.timeConsumingData,
      noteToPass: context.noteToPass,
      maxUploadSize: context.maxUploadSize,
      endpointPath: context.endpointPath,
      parameters: "\(context.parameters)",
      request_id: context.id,
      decoder: "\(context.requestDecoder)",
      encoder: "\(context.responseEncoder)",
      logger: "\(context.logger)" 
      )
  }

  //curl -i "http://localhost:8080/contextSpy/anythingHere"
  //"parameters": ... elements: [(key: \"number\", value: \"anythingHere\")] ...
  router.get("contextSpy/{number}") { _, context -> ContextInfo in
    ContextInfo(
      timeConsumingData: context.timeConsumingData,
      noteToPass: context.noteToPass,
      maxUploadSize: context.maxUploadSize,
      endpointPath: context.endpointPath,
      parameters: "\(context.parameters)",
      request_id: context.id,
      decoder: "\(context.requestDecoder)",
      encoder: "\(context.responseEncoder)",
      logger: "\(context.logger)" 
      )
  }
  
  let kiddiePoolRoutes = router.group("kiddiePool", context: RCJunior.self) 
  kiddiePoolRoutes.add(middleware: AlmostEmptyMiddleware(message: "kiddiePool A"))
  //curl -i "http://localhost:8080/kiddiePool/"
  kiddiePoolRoutes.get { _, context -> String in
        print("child route without \"number\"")
        return "CODE: \(context.magicNumber)"
  }

  //curl -i "http://localhost:8080/kiddiePool/354"
  kiddiePoolRoutes.get("{number}")  { _, context -> String in
        print("child route with \"number\"")
        return "CODE: \(context.magicNumber)"
  }

  //order matters. this middleware will apply to 
  //kiddiePoolRoutes.get("/magic/{number}/**") only. 
  kiddiePoolRoutes.add(middleware: AlmostEmptyMiddleware(message: "kiddiePool B"))

  
  //curl -i "http://localhost:8080/kiddiePool/magic/3/rabbit/saw/cards"
  kiddiePoolRoutes.get("/magic/{number}/**")  { request, context -> String in
        print("description:\(request.uri.description)")
        print("parameters:\(context.parameters.getCatchAll())")
        return "CODE: \(context.magicNumber)"
  }


  return router
}
