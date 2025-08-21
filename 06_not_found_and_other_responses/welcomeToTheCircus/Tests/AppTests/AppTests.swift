import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import welcomeToTheCircus

struct AppTests {
    struct TestArguments: AppArguments {
        let nameTag: String = "nwtTestServer"
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    let clownStore = ClownController(repository: ClownCar())

    @Test func testCreateApp() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/ping", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    }

    @Test func testPeanuts() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/peanuts", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "yummy peanuts")
            }
        }
    }


    @Test func testOrgan() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let sound = "BWHAHHHHH"
            let _ = try await client.execute(uri: "/organ/\(sound)", method: .get) { response in
                #expect(response.status == .ok)
                
                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "text/html")

                let body = String(buffer:response.body)
                #expect(body.contains(sound))
                #expect(body.contains("<p>\(sound)</p>"))
            }
        }
    }

    @Test func testAcrobat() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let acrobat = "thisisfine"
            let _ = try await client.execute(uri: "/acrobat/\(acrobat)", method: .get) { response in
                #expect(response.status == .ok)
                
                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "text/html")

                let body = String(buffer:response.body)
                #expect(body.contains(acrobat))
                #expect(body.contains("<p>__________\(acrobat)__________________________</p>"))
            }
        }
    }

    @Test func testPercentEncoding() async throws  {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let acrobat = "this is fine"
            let encodedAcrobat = acrobat.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "no_one_here"
            let _ = try await client.execute(uri: "/acrobat/\(encodedAcrobat)", method: .get) { response in
                #expect(response.status == .ok)
                
                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "text/html")

                let body = String(buffer:response.body)
                #expect(body.contains(acrobat))
                #expect(body.contains("<p>__________\(acrobat)__________________________</p>"))
            }
        }
    }
}
