#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Hummingbird
import HummingbirdTesting
import Logging
import Testing




@testable import htmlResponses

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
    
    
    //These are pretty minimal tests. Just that the routes exist.
    //Unhappy paths, valid HTML headers, valid HTML, that the content is as expected are
    //all things one might test in a more comprehensive suite. 
    
    @Test func testOrgan() async throws {
    	let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
        	let message = "myMessage"
            let _ = try await client.execute(uri: "/organ/\(message)", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    
    }
    
    @Test func testAcrobat() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
        	//http://localhost:8080/acrobat/not%20gonna%20fall
        	let message = "myMessage"
            let _ = try await client.execute(uri: "/acrobat/\(message)", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    
    
    }
}