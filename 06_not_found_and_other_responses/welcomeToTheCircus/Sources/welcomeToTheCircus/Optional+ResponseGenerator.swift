import Hummingbird

// This isn't what I want. 

// https://github.com/hummingbird-project/hummingbird/blob/fad01c3c0db7752f2a7e39d2b969bd59b1ab57a7/Sources/Hummingbird/Router/ResponseGenerator.swift#L89
// extension Optional: ResponseGenerator where Wrapped: ResponseGenerator {
//     public func response(from request: Request, context: some RequestContext) throws -> Response {
//         switch self {
//         case .some(let wrapped):
//             return try wrapped.response(from: request, context: context)
//         case .none:
//             return Response(status: .noContent, headers: [:], body: .init())
//         }
//     }
// }

// A lot of the CRUD API's I use treat .noContent (204) as a "operation was a 
// success, but nothing to say in the response body" 
// (https://www.rfc-editor.org/rfc/rfc7231#section-6.3.5),  
// and I guess that is what a nil return means in many cases. The function 
// completed and didn't throw. However for my prototyping purposes, a nil more 
// typically means the resource wasn't found or some other thing went wrong. 

// So I wrote a wrapper to make my tests pass until I can move everything over 
// to a `Result` type, but I'd rather, I think, do this as a Middleware for 
// like a whole region of API responses than hand wrap all of my Optionals. 

// TODO: Is this the type of thing a Middleware could catch or is it too late 
// in the game?

struct OptionalHandler<MyVal>: ResponseGenerator where MyVal: ResponseGenerator {
    let value: MyVal?
    let returnNoContent: Bool
    let nilIsBadRequest: Bool

    init(value: MyVal?, returnEmptySuccess: Bool = false, nilMeansBadRequest:Bool = false) {
        self.value = value
        self.returnNoContent = returnEmptySuccess
        self.nilIsBadRequest = nilMeansBadRequest
    }

    public func response(from request: Request, context: some RequestContext) throws -> Response {
        switch value {
        case nil:
            if nilIsBadRequest {
                return Response(status: .badRequest, headers: [:], body: .init())
            } else {
                return Response(status: .notFound, headers: [:], body: .init())
            }

        case .some(let wrapped):
            if returnNoContent {
                return Response(status: .noContent, headers: [:], body: .init())
            } else {
                return try wrapped.response(from: request, context: context)
            }

        }
    }

}


// struct EditableOptionalHandler<MyVal>: ResponseGenerator where MyVal: ResponseGenerator {
//     let value: MyVal?
//     let returnNoContent: Bool
//     let nilIsBadRequest: Bool
//     let headers:HTTPFields?
//     let body:ResponseBody?

//     init(value: MyVal?, returnEmptySuccess: Bool = false, nilMeansBadRequest:Bool = false) {
//         self.value = value
//         self.returnNoContent = returnEmptySuccess
//         self.nilIsBadRequest = nilMeansBadRequest
//         self.body = nil
//         self.headers = nil
//     }

//     public func response(from request: Request, context: some RequestContext) throws -> Response {
//         switch value {
//         case nil:
//             if nilIsBadRequest {
//                 return Response(status: .badRequest, headers: headers ?? [:], body: body ?? .init())
//             } else {
//                 return Response(status: .notFound, headers: headers ?? [:], body: body ?? .init())
//             }

//         case .some(let wrapped):
//             if returnNoContent {
//                 return Response(status: .noContent, headers: headers ?? [:])
//             } else {
//                 return try wrapped.response(from: request, context: context)
//             }

//         }
//     }

// }
