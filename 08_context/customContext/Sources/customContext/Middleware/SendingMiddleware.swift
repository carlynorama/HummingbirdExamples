import Hummingbird

struct SendingMiddleware<Context: ForwardingRequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        var contextToPassForward = context
        contextToPassForward.noteToPass = "Howdy future Middleware!"
        contextToPassForward.timeConsumingData = timeConsumingRequestProcessingTask(on: request)
        let response = try await next(request, contextToPassForward)
        return response
    }

    private func timeConsumingRequestProcessingTask(on request:Request) -> Int {
        return 732
    }
}