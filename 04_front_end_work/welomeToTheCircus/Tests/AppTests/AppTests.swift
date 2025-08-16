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

    @Test func testClown() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in

            let goodID = 1  //start with known good.
            let _ = try await client.execute(uri: "/clowns/\(goodID)", method: .get) { response in
                #expect(response.status == .ok)

                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "application/json; charset=utf-8")

                let clown = try JSONDecoder().decode(Clown.self, from: response.body)
                //print(clown)
                //In "real" app would pull this directly from the db using same ID.
                let compareTo = Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 12)
                #expect(clown.name == compareTo.name)
            }

            let badID = 53_253_622  //change to known unused value
            let _ = try await client.execute(uri: "/clowns/\(badID)", method: .get) { response in
                #expect(response.status == .noContent)
            }

            let notAnID = "jieoGEJg"  //change to malformed
            let _ = try await client.execute(uri: "/clowns/\(notAnID)", method: .get) { response in
                #expect(response.status == .badRequest)
            }
        }
    }

    @Test func testClowns() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in

            let goodClown = Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 12)
            let badClown = Clown(id: -1, name: "Pennywise", spareNoses: 86428916419)
            let _ = try await client.execute(uri: "/clowns/", method: .get) { response in
                #expect(response.status == .ok)

                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "application/json; charset=utf-8")

                let clowns = try JSONDecoder().decode([Clown].self, from: response.body)
                #expect(clowns.contains(where: { $0 == goodClown }))
                #expect(!clowns.contains(where: { $0 == badClown }))
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
}
