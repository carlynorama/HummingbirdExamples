import Hummingbird

// #if canImport(FoundationEssentials)
// import FoundationEssentials
// #else
// import Foundation
// #endif
import Mustache



struct ErrorInfo {
    let title: String
    let status: String
    let message: String
}

struct ErrorHTML:ResponseGenerator  {
    let message: String
    let status: HTTPResponse.Status

    let library: MustacheLibrary

    init(status: HTTPResponse.Status, message: String, library:MustacheLibrary) {
        self.message = message
        self.status = status
        self.library = library
        //should potentially confirm that an error template exists. 
    }

    private var html:String {
        if let result = try? render() {
            return result
        } else {
            return "??? oops."
        }
    }

    private func render() throws -> String? {
        let pageContent = ErrorInfo(title: "Error Finding Page", status: "\(status)", message: message)

        let rendered = library.render(
            pageContent,
            withTemplate: "error"
        )
        return rendered
    }

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let buffer = ByteBuffer(string: self.html)
        return .init(status: status, headers: [.contentType: "text/html"], body: .init(byteBuffer: buffer))
    }
}