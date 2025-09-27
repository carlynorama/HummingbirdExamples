//Use this to track where a Middleware does it's actions

import Hummingbird

public struct AlmostEmptyMiddleware<Context: RequestContext>: RouterMiddleware {
    let message:String
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        print("PPPPIIIIIIIIIIIIIINNNNNGGGG: \(message)")
        let response =  try await next(request, context)
        print("PPPPOOOOOOOOOOOOOONNNNNGGGG: \(message)")
        return response
    }
}