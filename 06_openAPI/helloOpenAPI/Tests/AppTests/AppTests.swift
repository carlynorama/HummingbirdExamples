#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Hummingbird
import HummingbirdTesting
import Logging
import Testing




@testable import circusServer

struct AppTests {
    struct TestArguments: AppArguments {
        let nameTag: String = "nwtTestServer"
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
    
}