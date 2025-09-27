import Hummingbird
import Logging

//https://www.rfc-editor.org/rfc/rfc7807
//https://swagger.io/blog/problem-details-rfc9457-api-error-handling/
//struct ProblemDetail<Extension:Codable>: Decodable, ResponseEncodable {
struct ProblemDetail: Decodable, ResponseEncodable {
  // let type:String //documentationURI
  let status: Int?
  let title: String
  let detail: String?
  //let moreInfo : Extension?

  init(withStatus: HTTPResponse.Status, details: String) {
    self.status = withStatus.code
    self.title = "\(withStatus.code): \(withStatus.reasonPhrase)"
    self.detail = details
    //self.moreInfo = .init(nilLiteral: ())
  }
}

public struct JSONErrorMiddleware<Context: RequestContext>: RouterMiddleware {

  public func handle(
    _ request: Request, context: Context, next: (Request, Context) async throws -> Response
  ) async throws -> Response {
    do {
      return try await next(request, context)
    } catch let error as HTTPError {

      if let accepts = request.headers[.accept] {
        // if accepts.contains("application/json") || accepts.contains("application/problem+json") {
        if !accepts.contains("text/html") {
          let problem = ProblemDetail(
            withStatus: error.status, 
            details: "\(error) from request to \(request.uri)")
          var response = try problem.response(from: request, context: context)
          response.status = error.status
          response.headers[.contentType] = "application/problem+json"
          return response
        }
      }
      throw error

    }

  }
}
