import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import circusServer

extension AppTests {

  @Suite("ClownAPITests") struct ClownAPITests {
    static let APIBase = "/api/v0/clowns"

    //MARK: STATIC HELPERS

    struct CreateRequest: Encodable {
      let name: String
      let spareNoses: Int?
    }

    static func create(name: String, spareNoses: Int? = nil, client: some TestClientProtocol)
      async throws -> Clown
    {
      let request = CreateRequest(name: name, spareNoses: spareNoses)
      let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
      return try await client.execute(uri: "\(APIBase)", method: .post, body: buffer) { response in
        //#expect(response.status == .created)
        //this version expects the clown back, so switch to 200
        //https://stackoverflow.com/questions/1860645/create-request-with-post-which-response-codes-200-or-201-and-content
        #expect(response.status == .ok)
        return try JSONDecoder().decode(Clown.self, from: response.body)
      }
    }

    static func get(id: Int, client: some TestClientProtocol) async throws -> Clown? {
      try await client.execute(uri: "\(APIBase)/\(id)", method: .get) { response in
        // either the get request returned an 200 status or it didn't return a Clown
        #expect(response.status == .ok || response.body.readableBytes == 0)
        if response.body.readableBytes > 0 {
          return try JSONDecoder().decode(Clown.self, from: response.body)
        } else {
          return nil
        }
      }
    }

    static func list(client: some TestClientProtocol) async throws -> [Clown] {
      try await client.execute(uri: "\(APIBase)", method: .get) { response in
        #expect(response.status == .ok)
        return try JSONDecoder().decode([Clown].self, from: response.body)
      }
    }

    struct UpdateRequest: Encodable {
      let name: String?
      let spareNoses: Int?
      let completed: Bool?
    }

    static func patch(
      id: Int, name: String? = nil, spareNoses: Int? = nil, completed: Bool? = nil,
      client: some TestClientProtocol
    ) async throws -> Clown? {
      let request = UpdateRequest(name: name, spareNoses: spareNoses, completed: completed)
      let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
      return try await client.execute(uri: "\(APIBase)/\(id)", method: .patch, body: buffer) {
        response in
        #expect(response.status == .ok, "\(response.status)")
        if response.body.readableBytes > 0 {
          return try JSONDecoder().decode(Clown.self, from: response.body)
        } else {
          return nil
        }
      }
    }
    //
    //    //for testing uuid is just a string so can pass garbage later.
    static func patchResponseStatus(
      id: String, name: String? = nil, spareNoses: Int? = nil, completed: Bool? = nil,
      client: some TestClientProtocol
    ) async throws -> HTTPResponse.Status {
      let request = UpdateRequest(name: name, spareNoses: spareNoses, completed: completed)
      let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
      return try await client.execute(uri: "\(APIBase)/\(id)", method: .patch, body: buffer) {
        response in
        response.status
      }
    }

    static func delete(id: Int, client: some TestClientProtocol) async throws -> HTTPResponse.Status
    {
      try await client.execute(uri: "\(APIBase)/\(id)", method: .delete) { response in
        response.status
      }
    }

    static func deleteAll(client: some TestClientProtocol) async throws -> HTTPResponse.Status {
      try await client.execute(uri: "\(APIBase)", method: .delete) { response in
        response.status
      }
    }

    //MARK: TESTS

    //MARK: Test Hellos

    @Test func testHello() async throws {
      let app = try await buildApplication(TestArguments())
      try await app.test(.router) { client in
        try await client.execute(uri: "\(Self.APIBase)/hello", method: .get) { response in
          #expect(response.status == .ok)
          //print(String(buffer: response.body))
          #expect(response.headers.contains(.contentType))
          let contentType = response.headers[.contentType]!
          #expect(contentType == "text/plain", "contentType:\(contentType)")
          #expect(
            response.body == ByteBuffer(string: "Hello!"),
            "test url did not return expected phrase.")
        }
      }
    }

    @Test func testFormalHello() async throws {
      let app = try await buildApplication(TestArguments())
      try await app.test(.router) { client in
        try await client.execute(uri: "\(Self.APIBase)/helloworld", method: .get) { response in
          #expect(response.status == .ok)
          print(String(buffer: response.body))
          #expect(response.status == .ok)

          #expect(response.headers.contains(.contentType))
          let contentType = response.headers[.contentType]!
          #expect(contentType == "application/json; charset=utf-8")

          let json = try JSONSerialization.jsonObject(with: response.body, options: [])
          let object = json as? [String: String]  // {
          #expect(object != nil, "expected cast of response body to [String:String] dict to work.")

          let message = object!["message"]
          #expect(message != nil, "expected for the key (message) to be valid.")

          #expect(
            message == "Hello, world!", "test url did not return expected phrase.")
        }
      }
    }

    //MARK: Test Create

    @Test func testCreate() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let clownName = "Bozo"
        let noseCount = 17
        let clown = try await Self.create(name: clownName, spareNoses: noseCount, client: client)
        print(clown)
        #expect(clown.name == clownName)
        #expect(clown.spareNoses == noseCount)

        let retrievedClown = try await Self.get(id: clown.id, client: client)
        #expect(clown == retrievedClown)
      }
    }

    //MARK: Test Reads
    @Test func testClownFetch() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in

        let goodID = 1  //start with known good.
        let _ = try await client.execute(uri: "\(Self.APIBase)/\(goodID)", method: .get) {
          response in
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
        let _ = try await client.execute(uri: "\(Self.APIBase)/\(badID)", method: .get) {
          response in
          #expect(response.status == .notFound)
        }

        let notAnID = "jieoGEJg"  //change to malformed
        let _ = try await client.execute(uri: "\(Self.APIBase)/\(notAnID)", method: .get) {
          response in
          // TODO: THIS IS BAD
          // EXAMPLE OF 500 PROBLEM!!!
          // #expect(response.status == .badRequest)
          #expect(response.status == .internalServerError)
        }
      }
    }

    @Test func testClownsFetch() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        //this is weak. If the test data, not currently managed by the test suite,
        //changes, these test could fail based on that.
        let goodClown = Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 41417)
        let badClown = Clown(id: -1, name: "Pennywise", spareNoses: 86_428_916_419)
        let _ = try await client.execute(uri: "\(Self.APIBase)/", method: .get) { response in
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

    //MARK: Test Updates
    @Test func testUpdateBoth() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let knownGoodID = 4
        let newName = "Bozo Jr."
        let newNoseCount = 18
        let beforeClown = try await Self.get(id: knownGoodID, client: client)
        let clown = try await Self.patch(
          id: knownGoodID, name: newName, spareNoses: newNoseCount, client: client)
        #expect(clown != nil)
        #expect(clown!.name == newName)
        #expect(clown!.spareNoses == newNoseCount)
        #expect(clown!.name != beforeClown?.name)
        #expect(clown!.spareNoses != beforeClown?.spareNoses)
        #expect(clown!.id == beforeClown?.id)

        let retrievedClown = try await Self.get(id: clown!.id, client: client)
        #expect(clown == retrievedClown)
        let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
        #expect(retrievedClown == retrievedOrigIDClown)
      }
    }

    @Test func testUpdateBadId() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let knownBadID = 890_379_023
        let newName = "Bozo Jr."
        let newNoseCount = 18
        let _ = try await client.execute(uri: "\(Self.APIBase)/\(knownBadID)", method: .get) {
          response in
          #expect(response.status == .notFound)
        }
        var updateStatus = try await Self.patchResponseStatus(
          id: "\(knownBadID)", name: newName, spareNoses: newNoseCount, client: client)
        #expect(updateStatus == .badRequest)

        updateStatus = try await Self.patchResponseStatus(
          id: "fgu8ik56gw3R)", name: newName, spareNoses: newNoseCount, client: client)

        // TODO: THIS IS BAD
        // EXAMPLE OF 500 PROBLEM!!!
        // #expect(updateStatus == .badRequest)
        #expect(updateStatus == .internalServerError)

      }
    }

    //	//TODO: test the nose
    //
    // @Test func testNoseDecrement() async throws {
    //   let app = try await buildApplication(TestArguments())

    //   try await app.test(.router) { client in
    //     let knownGoodID = 1
    //     let beforeClown = try await Self.get(id: knownGoodID, client: client)
    //     #expect(beforeClown != nil)
    //     let replyClown: Clown? = try await client.execute(
    //       uri: "clowns/\(knownGoodID)/honk", method: .patch
    //     ) { response in
    //       // either the get request returned an 200 status or it didn't return a Clown
    //       //#expect(response.status == .ok || response.body.readableBytes == 0)
    //       if response.body.readableBytes > 0 {
    //         // print(String(buffer: response.body))
    //         return try JSONDecoder().decode(Clown.self, from: response.body)
    //       } else {
    //         // print("empty body?")
    //         // print(response)
    //         return nil
    //       }
    //     }

    //     #expect(replyClown != nil)
    //     #expect(replyClown!.name == beforeClown?.name)
    //     #expect(replyClown!.spareNoses != beforeClown?.spareNoses)
    //     #expect(replyClown!.spareNoses + 1 == beforeClown?.spareNoses)
    //     #expect(replyClown!.id == beforeClown?.id)
    //   }
    // }

    @Test func testUpdateName() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let knownGoodID = 4
        let newName = "Bozo Jr."
        let beforeClown = try await Self.get(id: knownGoodID, client: client)
        let clown = try await Self.patch(id: knownGoodID, name: newName, client: client)
        #expect(clown != nil)
        #expect(clown!.name == newName)
        #expect(clown!.name != beforeClown?.name)
        #expect(clown!.spareNoses == beforeClown?.spareNoses)
        #expect(clown!.id == beforeClown?.id)

        let retrievedClown = try await Self.get(id: clown!.id, client: client)
        #expect(clown == retrievedClown)
        let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
        #expect(retrievedClown == retrievedOrigIDClown)
      }
    }

    //    //MARK: Test Deletes
    @Test func testDelete() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let knownGoodID = 4
        let beforeClown = try await Self.get(id: knownGoodID, client: client)
        #expect(beforeClown != nil)
        let status = try await Self.delete(id: knownGoodID, client: client)
        #expect(status == .ok)
        try await client.execute(uri: "\(Self.APIBase)/\(knownGoodID)", method: .get) { response in
          #expect(response.status == .notFound)
        }
        try await client.execute(uri: "\(Self.APIBase)/\(knownGoodID)", method: .delete) {
          response in
          #expect(response.status == .badRequest)
        }
      }

    }

    @Test func testDeleteAll() async throws {
      let app = try await buildApplication(TestArguments())

      try await app.test(.router) { client in
        let knownGoodID = 4
        let beforeClown = try await Self.get(id: knownGoodID, client: client)
        #expect(beforeClown != nil)
        let status = try await Self.deleteAll(client: client)
        #expect(status == .ok)
        try await client.execute(uri: "\(Self.APIBase)/\(knownGoodID)", method: .get) { response in
          #expect(response.status == .notFound)
        }
        try await client.execute(uri: "\(Self.APIBase)/\(knownGoodID)", method: .delete) {
          response in
          #expect(response.status == .badRequest)
        }

        let deletedClowns = try await Self.list(client: client)
        #expect(deletedClowns.isEmpty)
      }
    }
  }
}
