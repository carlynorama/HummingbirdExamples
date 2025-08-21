// TODO: Is this going to a provided Middleware in Hummingbird eventually?
// - https://github.com/hummingbird-project/hummingbird/issues/580
// - https://github.com/hummingbird-project/hummingbird/issues/592

// router.addMiddleware {
//     NotFoundMiddleware()
//     FileMiddleware(
//         rootPath,
//         searchForIndexHtml: true,
//         logger: logger
//     )
// }


//TODO: Back to Referrer?
//TODO: What had they been looking for?

import Hummingbird

enum NotFoundResponse {
    case redirect(to: String)
    case basicPage
    case string(String)
    case custom(Response)

    var response: Response {
        switch self {

        case .redirect(let notFoundRoute):
            return Response(
                status: .seeOther,
                headers: [
                    .location: notFoundRoute
                ]
            )
        case .basicPage:
            return basic404PageResponse

        case .custom(let provided):
            return provided

        case .string(let message):
            return stringResponse(message)

        }
    }

    func stringResponse(_ message: String) -> Response {
        let responseBody = ResponseBody(byteBuffer: ByteBuffer(string: message))
        //TODO: This needs some other headers?
        return Response(
            status: .notFound,
            headers: [.contentType: "text/plain; charset=UTF-8"],
            body: responseBody)
    }

    //TODO: write an actual page. 
    var basic404PageResponse: Response {
        let responseBody = ResponseBody(byteBuffer: ByteBuffer(staticString: """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Not Found</title>
            <meta charset="UTF-8">

        </head>
        <body>
        <p>The resource you were looking for wasn't found.</p>
        <p><a href="/">back to home</a>.</p>
        </body>
        </html>
        
        """))
        //TODO: This needs some other headers?
        return Response(
            status: .notFound,
            headers: [.contentType: "text/html; charset=UTF-8"],
            body: responseBody)
    }

    //Not currently in use. 
    static func generateHTMLForMessage(_ message:String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Hear the Music!!!</title>
            <meta charset="UTF-8">

        </head>
        <body>
        <p>\(message)</p>
        <p><a href="/">back to index</a>.</p>
        </body>
        </html>
        """
    }

}

struct NotFoundMiddleware<Context: RequestContext>: RouterMiddleware {

    let notFoundResponse: NotFoundResponse?
    let defaultResponse = NotFoundResponse.basicPage.response

    func handle(
        _ request: Request,
        context: Context,
        next: (
            Request,
            Context
        ) async throws -> Response
    ) async throws -> Response {
        do {
            return try await next(request, context)
        } catch let error as HTTPError {
            if error.status == .notFound {
                return notFoundResponse?.response ?? defaultResponse
            }
            throw error
        }
    }

}
