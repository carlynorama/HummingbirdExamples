import Hummingbird

struct ReceivingMiddleware<Context: ForwardingRequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        print(context.noteToPass ?? "no message from Ping")
        if context.timeConsumingData != nil {
            useResultOfTimeConsumingProcess(number: context.timeConsumingData!)
        }
        return try await next(request, context)
    }

    private func useResultOfTimeConsumingProcess(number: Int) {
        print("\(number) is a big number!")
    }
}