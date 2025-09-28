import Hummingbird

struct ReceivingMiddleware<Context: ForwardingRequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        print("receiving...")
        
        var contextToPass = context

        print("Receiver got: \(context.noteToPass ?? "no message from sender")")
        contextToPass.noteToPass = "Receiver says hi too!"

        if context.timeConsumingData != nil {
            contextToPass.timeConsumingData = myTwoCents(number: context.timeConsumingData!)
        }
        return try await next(request, contextToPass)
    }

    private func myTwoCents(number: Int) -> Int {
        print("\(number) is a big number!")
        return number + 2
    }
}