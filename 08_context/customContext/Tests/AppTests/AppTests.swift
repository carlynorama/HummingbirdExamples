#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Hummingbird
import HummingbirdTesting
import Logging
import Testing


@testable import customContext

struct AppTests {
    struct TestArguments: AppArguments {
        let nameTag: String = "cstmCntxTestServer"
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    
    @Test func testCreateApp() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/ping", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    }

    @Test func testContextSpy() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/contextSpy", method: .get) { response in
                #expect(response.status == .ok)
                let decoded = try JSONDecoder().decode(ContextInfo.self, from: response.body)
                #expect(decoded.noteToPass == "Receiver says hi too!")
                #expect(decoded.timeConsumingData == nil)
            }
        }
    }

    @Test func testContextSpyWithNumber() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let number = 65
            let _ = try await client.execute(uri: "/contextSpy/\(number)", method: .get) { response in
                #expect(response.status == .ok)
                let decoded = try JSONDecoder().decode(ContextInfo.self, from: response.body)
                #expect(decoded.noteToPass == "Receiver says hi too!")
                //Hummingbird tests suite does not provide a User Agent. 
                #expect(decoded.timeConsumingData == 2+732+number)
            }
        }

        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/contextSpy/notANumber", method: .get) { response in
                #expect(response.status == .ok)
                let decoded = try JSONDecoder().decode(ContextInfo.self, from: response.body)
                #expect(decoded.noteToPass == "Receiver says hi too!")
                #expect(decoded.timeConsumingData == nil)
            }
        }
    }


    @Test func testKiddiePool() async throws {
        let app = try await buildApplication(TestArguments())
        
        //with number
        let number = 65
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/kiddiePool/\(number)", method: .get) { response in
                #expect(response.status == .ok)
                let decoded = String(bytes: response.body.readableBytesView, encoding: .utf8 )
                //Hummingbird tests suite does not provide a User Agent.
                let expectedTotal =  2+732+number
                #expect(decoded == "CODE: \(expectedTotal)")
            }
        }

        //something in the path that is not a number
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/kiddiePool/notANumber", method: .get) { response in
                print(response.status)
                #expect(response.status.code == 418)
            }
        }

        //base, nothing else
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/kiddiePool/", method: .get) { response in
                print(response.status)
                #expect(response.status.code == 418)
            }
        }
    }

}