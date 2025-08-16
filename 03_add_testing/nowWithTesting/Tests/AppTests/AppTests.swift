
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

import Foundation


@testable import nowWithTesting

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

    @Test func testGoodbye() async throws{
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/goodbye", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "Ciao!")

            }
        }
    }

    @Test func testEncodable() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/encodable", method: .get) { response in
                #expect(response.status == .ok)
                //print(String(buffer: response.body))
                #expect(String(buffer: response.body) == "{\"number\":5,\"phrase\":\"hello!\"}")

            }
        }
    }

    @Test func testSingleWild() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in

            let _ = try await client.execute(uri: "/files/", method: .get) { response in
                #expect(response.status == .notFound)
            }

            let _ = try await client.execute(uri: "/files/testPhrase", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "/files/testPhrase")
            }

            let _ = try await client.execute(uri: "/files/too/many/things", method: .get) { response in
                #expect(response.status == .notFound)
            }
        }
    }

    @Test func testUser() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in

            let _ = try await client.execute(uri: "/user/garbfjfesage", method: .get) { response in
                #expect(response.status == .badRequest)
            }

            var intToTest = 43
            let _ = try await client.execute(uri: "/user/\(intToTest)", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "\(intToTest)")
            }

            intToTest = 43131
            let _ = try await client.execute(uri: "/user/\(intToTest)", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "\(intToTest)")
            }

            intToTest = -13214
            let name = "some crazy string"
            let _ = try await client.execute(uri: "/user/\(intToTest)/\(name)", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "found \(name) for \(intToTest)")
            }
        }
    }

    struct MiniCodable:Decodable, ResponseEncodable {
        let number: Int
        let phrase: String?
    }

    @Test func testDecoding() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/decodable/default", method: .post) { response in
                #expect(response.status == .badRequest)
            }


            let codedData = MiniCodable(number: 34, phrase:"something to say")

            var buffer = try JSONEncoder().encodeAsByteBuffer(codedData, allocator: ByteBufferAllocator())
            // print("coded: \(String(buffer:buffer))")
            // var buffer = ByteBuffer(string: "{\"phrase\":\"something to say\",\"number\":34}" )
            let _ = try await client.execute(uri: "/decodable/default", method: .post, body:buffer) { response in
                #expect(response.status == .ok)
                print("responseBody default: \(String(buffer: response.body))")

                //TODO: json shows up in arbitrary order.
                //let testString:String = "{\"phrase\":\"\(codedData.phrase!)\",\"number\":\(codedData.number)}"

                #expect(String(buffer: response.body).contains("\"number\":\(codedData.number)"))
                #expect(String(buffer: response.body).contains("\"phrase\":\"\(codedData.phrase!)\""))
            }

            
            buffer = ByteBuffer(string: "number=\(codedData.number)&phrase=\"\(codedData.phrase)\"")
            let _ = try await client.execute(uri: "/decodable/form", method: .post, body:buffer) { response in
                #expect(response.status == .ok)
                print("responseBody form: \(String(buffer: response.body))")
                #expect(String(buffer: response.body).contains("\"number\":\(codedData.number)"))
                //THIS TEST FAILS b/c Optional()
                #expect(String(buffer: response.body).contains("\"phrase\":\"\(codedData.phrase!)\""))
            }
        }
    }

//     @discardableResult
// func execute<Return>(
//     uri: String,
//     method: HTTPRequest.Method,
//     headers: HTTPFields = [:],
//     body: ByteBuffer? = nil,
//     testCallback: @escaping (TestResponse) async throws -> Return = { $0 }
// ) async throws -> Return

}