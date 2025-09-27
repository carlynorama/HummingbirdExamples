//Variation on
//https://github.com/hummingbird-project/hummingbird-examples/blob/97a09f0664679f017616a82894848b267c5e7068/todos-auth-fluent/Sources/App/Middleware/ErrorPageMiddleware.swift#L19

import Hummingbird
import Mustache

/// Generate an HTML page for a thrown error
struct ErrorPageMiddleware<Context: RequestContext>: RouterMiddleware {
    let mustacheLibrary: MustacheLibrary

    func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Response
    ) async throws -> Response {
        do {
            return try await next(request, context)
        } catch {
            if let error = error as? HTTPError {
                return try ErrorHTML(status: error.status, message: error.body ?? "", library: mustacheLibrary).response(from: request, context: context)
            } else {
                return try ErrorHTML(status: HTTPResponse.Status.internalServerError, message: "\(error)", library: mustacheLibrary).response(from: request, context: context)
                
            }
        }
    }
}