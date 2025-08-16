
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

import Foundation


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
        let app = try await buildApplication(TestArguments(), clownStore:clownStore)
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/ping", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    }

    @Test func testPeanuts() async throws {
        let app = try await buildApplication(TestArguments(), clownStore:clownStore)
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/peanuts", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "yummy peanuts")
            }
        }
    }

    @Test func testClown() async throws {
        let app = try await buildApplication(TestArguments(), clownStore:clownStore)
        let idToCheck = 1 //start with known good.
        try await app.test(.router) { client in
            let _ = try await client.execute(uri: "/clowns/\(idToCheck)", method: .get) { response in
                #expect(response.status == .ok)
                let clown = try JSONDecoder().decode(Clown.self, from: response.body)
                print(clown)
                //In "real" app would pull this directly from the db using same ID. 
                let compareTo = Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 12)
                #expect(clown.name == compareTo.name)
            }

            //change to known bad 
            let badID = 53253622
            let _ = try await client.execute(uri: "/clowns/\(badID)", method: .get) { response in
                #expect(response.status == .noContent)
            }

            let notAnID = "jieoGEJg"
            let _ = try await client.execute(uri: "/clowns/\(notAnID)", method: .get) { response in
                #expect(response.status == .badRequest)
            }
        }
    }



    //         <li>where one can get <a href=/peanuts>peanuts</a></li>
    //     <li>with a ring for <a href="/clowns">clowns</a></li>
    //     <ul><li>that can be called <a href="/clowns/4">by id</a></li></ul>
    //   </ul>
    // <li>These links return generated HTML pages as their response bodies</li>
    //   <ul>
    //     <li><a href=/organ/LaTaDadaDadaLaTaDaDah>organ music</a></li>
    //     <li><a href=/acrobat/notgonnafall>acrobat</a></li>

    // @Test func testGoodbye() async throws{
    //     let app = try await buildApplication(TestArguments())
    //     try await app.test(.router) { client in
    //         let _ = try await client.execute(uri: "/goodbye", method: .get) { response in
    //             #expect(response.status == .ok)
    //             #expect(String(buffer: response.body) == "Ciao!")

    //         }
    //     }
    // }

    // @Test func testEncodable() async throws {
    //     let app = try await buildApplication(TestArguments())
    //     try await app.test(.router) { client in
    //         let _ = try await client.execute(uri: "/encodable", method: .get) { response in
    //             #expect(response.status == .ok)
    //             //print(String(buffer: response.body))
    //             #expect(String(buffer: response.body) == "{\"number\":5,\"phrase\":\"hello!\"}")

    //         }
    //     }
    // }

    // @Test func testSingleWild() async throws {
    //     let app = try await buildApplication(TestArguments())
    //     try await app.test(.router) { client in

    //         let _ = try await client.execute(uri: "/files/", method: .get) { response in
    //             #expect(response.status == .notFound)
    //         }

    //         let _ = try await client.execute(uri: "/files/testPhrase", method: .get) { response in
    //             #expect(response.status == .ok)
    //             #expect(String(buffer: response.body) == "/files/testPhrase")
    //         }

    //         let _ = try await client.execute(uri: "/files/too/many/things", method: .get) { response in
    //             #expect(response.status == .notFound)
    //         }
    //     }
    // }

    // @Test func testUser() async throws {
    //     let app = try await buildApplication(TestArguments())
    //     try await app.test(.router) { client in

    //         let _ = try await client.execute(uri: "/user/garbfjfesage", method: .get) { response in
    //             #expect(response.status == .badRequest)
    //         }

    //         var intToTest = 43
    //         let _ = try await client.execute(uri: "/user/\(intToTest)", method: .get) { response in
    //             #expect(response.status == .ok)
    //             #expect(String(buffer: response.body) == "\(intToTest)")
    //         }

    //         intToTest = 43131
    //         let _ = try await client.execute(uri: "/user/\(intToTest)", method: .get) { response in
    //             #expect(response.status == .ok)
    //             #expect(String(buffer: response.body) == "\(intToTest)")
    //         }

    //         intToTest = -13214
    //         let name = "some crazy string"
    //         let _ = try await client.execute(uri: "/user/\(intToTest)/\(name)", method: .get) { response in
    //             #expect(response.status == .ok)
    //             #expect(String(buffer: response.body) == "found \(name) for \(intToTest)")
    //         }
    //     }
    // }

    // struct MiniCodable:Decodable, ResponseEncodable {
    //     let number: Int
    //     let phrase: String?
    // }

    // @Test func testDecoding() async throws {
    //     let app = try await buildApplication(TestArguments())
    //     try await app.test(.router) { client in
    //         let _ = try await client.execute(uri: "/decodable/default", method: .post) { response in
    //             #expect(response.status == .badRequest)
    //         }


    //         let codedData = MiniCodable(number: 34, phrase:"something to say")

    //         var buffer = try JSONEncoder().encodeAsByteBuffer(codedData, allocator: ByteBufferAllocator())
    //         // print("coded: \(String(buffer:buffer))")
    //         // var buffer = ByteBuffer(string: "{\"phrase\":\"something to say\",\"number\":34}" )
    //         let _ = try await client.execute(uri: "/decodable/default", method: .post, body:buffer) { response in
    //             #expect(response.status == .ok)
    //             print("responseBody default: \(String(buffer: response.body))")

    //             //TODO: json shows up in arbitrary order. check against a dictionary?
    //             //let testString:String = "{\"phrase\":\"\(codedData.phrase!)\",\"number\":\(codedData.number)}"

    //             #expect(String(buffer: response.body).contains("\"number\":\(codedData.number)"))
    //             #expect(String(buffer: response.body).contains("\"phrase\":\"\(codedData.phrase!)\""))
    //         }

            
    //         buffer = ByteBuffer(string: "number=\(codedData.number)&phrase=\(codedData.phrase!)")
    //         let _ = try await client.execute(uri: "/decodable/form", 
    //                                         method: .post, 
    //                                         //need header if detecting based on header, which not yet.
    //                                         //headers: [.contentType: "application/x-www-form-urlencoded"], 
    //                                         body:buffer) { response in
    //             #expect(response.status == .ok)
    //             print("responseBody form: \(String(buffer: response.body))")
    //             #expect(String(buffer: response.body).contains("\"number\":\(codedData.number)"))
    //             //THIS TEST FAILS b/c Optional()
    //             #expect(String(buffer: response.body).contains("\"phrase\":\"\(codedData.phrase!)\""))
    //         }
    //     }
    // }

}