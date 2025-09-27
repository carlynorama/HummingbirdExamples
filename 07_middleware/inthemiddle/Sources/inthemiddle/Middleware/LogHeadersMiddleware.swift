import Hummingbird
import Logging

public struct LogHeadersMiddleware<Context: RequestContext>: RouterMiddleware {
    var level:Logger.Level

    func formatHeaderForLog(headers: HTTPFields) -> String {
                var forLog = ""
        
        for header in headers {
            forLog.append("\t\(header.name):\(header.value)\n")
        }
        forLog.append("------")
        return forLog
    }

    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {

        let requestHeaders = formatHeaderForLog(headers: request.headers)
        context.logger.log(level: level, Logger.Message(stringLiteral: "\nHeaders for \(request.uri.path) request:\n\(requestHeaders)"))

        //return Response
        let response = try await next(request, context)

        let responseHeaders = formatHeaderForLog(headers: response.headers)
        let status = response.status
        context.logger.log(level: level, Logger.Message(stringLiteral: "\nResponding \(status) with:\n\(responseHeaders)"))

        return response
    }
}