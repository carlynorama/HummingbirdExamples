import Hummingbird
import Logging

public struct LogErrorsMiddleware<Context: RequestContext>: RouterMiddleware {
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
        do {
            return try await next(request, context)
        } catch let error as HTTPError {
            let status = error.status
            let formattedHeaders = formatHeaderForLog(headers: error.headers)
            context.logger.log(level: level, Logger.Message(stringLiteral: "\nResponding \(status) to \(request.uri) call:\n\(formattedHeaders)"))
            throw error
        }

    }
}