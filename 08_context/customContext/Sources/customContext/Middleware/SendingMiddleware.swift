import Hummingbird

struct SendingMiddleware<Context: ForwardingRequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        print("sending...")

        var contextToPassForward = context
        contextToPassForward.noteToPass = "Howdy future Middleware!"
        

        if let pathNumber = Int(context.parameters.get("number") ?? "nope.") {
            let requestNumber = timeConsumingRequestProcessingTask(on: request)
            contextToPassForward.timeConsumingData = pathNumber + requestNumber
        }

        let response = try await next(request, contextToPassForward)
        return response
    }

    private func timeConsumingRequestProcessingTask(on request:Request) -> Int {
        if let agent = request.headers[.userAgent] {
            print("\(agent) wants to play. \(agent.count)")
            return agent.count
        }
        return 732
    }
}