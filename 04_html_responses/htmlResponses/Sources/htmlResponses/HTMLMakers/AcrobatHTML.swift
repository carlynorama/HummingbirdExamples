import Hummingbird

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Mustache



struct BasicInfo {
    let title: String
    let message: String
}

struct AcrobatHTML:ResponseGenerator  {
    // load mustache template library

    let message: String
    let library: MustacheLibrary

    init(_ message: String, library:MustacheLibrary) {
        self.message = message
        self.library = library
    }

    private var html:String {
        if let result = try? render() {
            return result
        } else {
            return "??? oops."
        }
    }

    private func render() throws -> String? {
        let messagePost = BasicInfo(title: "I'm a Message!", message: message)

        let rendered = library.render(
            messagePost,
            withTemplate: "base"
        )
        return rendered
    }

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let buffer = ByteBuffer(string: self.html)
        return .init(status: .ok, headers: [.contentType: "text/html"], body: .init(byteBuffer: buffer))
    }
}