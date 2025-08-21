import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import welcomeToTheCircus

extension AppTests {


    //MARK: STATIC HELPERS


    struct CreateRequest: Encodable {
        let name: String
        let spareNoses: Int?
    }


    static func create(name: String, spareNoses: Int? = nil, client: some TestClientProtocol) async throws -> Clown {
        let request = CreateRequest(name: name, spareNoses: spareNoses)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/clowns", method: .post, body: buffer) { response in
            #expect(response.status == .created)
            return try JSONDecoder().decode(Clown.self, from: response.body)
        }
    }

    static func formCreate(name: String, spareNoses: Int? = nil, client: some TestClientProtocol) async throws -> Clown {
        let request = CreateRequest(name: name, spareNoses: spareNoses)
        let buffer = ByteBuffer(string:try URLEncodedFormEncoder().encode(request))
        return try await client.execute(uri: "/clowns/form/join", method: .post, body: buffer) { response in
            #expect(response.status == .created)
            return try JSONDecoder().decode(Clown.self, from: response.body)
        }
    }


    static func get(id: Int, client: some TestClientProtocol) async throws -> Clown? {
        try await client.execute(uri: "/clowns/\(id)", method: .get) { response in
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
        try await client.execute(uri: "/clowns", method: .get) { response in
            #expect(response.status == .ok)
            return try JSONDecoder().decode([Clown].self, from: response.body)
        }
    }


    struct UpdateRequest: Encodable {
        let name: String?
        let spareNoses: Int?
        let completed: Bool?
    }


    static func patch(id: Int, name: String? = nil, spareNoses: Int? = nil, completed: Bool? = nil, client: some TestClientProtocol) async throws -> Clown? {
        let request = UpdateRequest(name: name, spareNoses: spareNoses, completed: completed)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/clowns/\(id)", method: .patch, body: buffer) { response in
            #expect(response.status == .ok, "\(response.status)")
            if response.body.readableBytes > 0 {
                return try JSONDecoder().decode(Clown.self, from: response.body)
            } else {
                return nil
            }
        }
    }

    //for testing uuid is just a string so can pass garbage later. 
    static func patchResponseStatus(id: String, name: String? = nil, spareNoses: Int? = nil, completed: Bool? = nil, client: some TestClientProtocol) async throws -> HTTPResponse.Status {
        let request = UpdateRequest(name: name, spareNoses: spareNoses, completed: completed)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/clowns/\(id)", method: .patch, body: buffer) { response in
            response.status
        }
    }


    static func delete(id: Int, client: some TestClientProtocol) async throws -> HTTPResponse.Status {
        try await client.execute(uri: "/clowns/\(id)", method: .delete) { response in
            response.status
        }
    }

    struct DeleteRequest: Encodable {
        let id: Int
        let name: String
        
    }

    static func formDelete(id: Int, name: String, client: some TestClientProtocol) async throws -> HTTPResponse.Status {
        let request = DeleteRequest(id:id, name: name)
        let buffer = ByteBuffer(string:try URLEncodedFormEncoder().encode(request))
        return try await client.execute(uri: "/clowns/form/leave", method: .post, body: buffer) { response in
            return response.status
        }
    }


    static func deleteAll(client: some TestClientProtocol) async throws -> HTTPResponse.Status {
        try await client.execute(uri: "/clowns", method: .delete) { response in 
            response.status
        }
    }


    //MARK: TESTS 


    @Test func testClownFetch() async throws {
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
                #expect(response.status == .notFound)
            }

            //TODO: research opinions on badRequest and Type Validation.
            let notAnID = "jie8oGEJg"  //change to malformed 
            let _ = try await client.execute(uri: "/clowns/\(notAnID)", method: .get) { response in
                #expect(response.status == .badRequest)
                //#expect(response.status == .unprocessableContent)
            }
        }
    }

    @Test func testClownsFetch() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in

            //TODO: change this to fetching a random clown from the repos.
            let goodClown = Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 41417)
            let badClown = Clown(id: -1, name: "Pennywise", spareNoses: 86428916419)
            let _ = try await client.execute(uri: "/clowns/", method: .get) { response in
                #expect(response.status == .ok)

                #expect(response.headers.contains(.contentType))
                let contentType = response.headers[.contentType]!
                #expect(contentType == "application/json; charset=utf-8")

                let clowns = try JSONDecoder().decode([Clown].self, from: response.body)
                print(clowns)
                #expect(clowns.contains(where: { $0 == goodClown }))
                #expect(!clowns.contains(where: { $0 == badClown }))
            }
        }
    }

    @Test func testCreate() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let clownName = "Bozo"
            let noseCount = 17
            let clown = try await Self.create(name: clownName, spareNoses: noseCount, client: client)
            #expect(clown.name == clownName )
            #expect(clown.spareNoses == noseCount )

            let retrievedClown = try await Self.get(id: clown.id, client: client)
            #expect(clown == retrievedClown)
        }
    }

    @Test func testFormCreate() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let clownName = "Bozo"
            let noseCount = 17
            let clown = try await Self.formCreate(name: clownName, spareNoses: noseCount, client: client)
            #expect(clown.name == clownName )
            #expect(clown.spareNoses == noseCount )

            let retrievedClown = try await Self.get(id: clown.id, client: client)
            #expect(clown == retrievedClown)
        }
    }

    //MARK: Test Updates
    @Test func testUpdateBoth() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let newName = "Bozo Jr."
            let newNoseCount = 18
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            let clown = try await Self.patch(id: knownGoodID, name:newName, spareNoses: newNoseCount, client: client)
            #expect(clown != nil)
            #expect(clown!.name == newName )
            #expect(clown!.spareNoses == newNoseCount )
            #expect(clown!.name != beforeClown?.name )
            #expect(clown!.spareNoses != beforeClown?.spareNoses)
            #expect(clown!.id == beforeClown?.id)

            let retrievedClown = try await Self.get(id: clown!.id, client: client)
            #expect(clown == retrievedClown)
            let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
            #expect(retrievedClown == retrievedOrigIDClown)
        }
    }

    @Test func testUpdateBadId() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownBadID = 890379023
            let newName = "Bozo Jr."
            let newNoseCount = 18
            let _ = try await client.execute(uri: "/clowns/\(knownBadID)", method: .get) { response in
                #expect(response.status == .notFound)
            }
            var updateStatus = try await Self.patchResponseStatus(id:"\(knownBadID)", name: newName, spareNoses: newNoseCount, client: client)
            #expect(updateStatus == .notFound)

            updateStatus = try await Self.patchResponseStatus(id:"fgu8ik56gw3R)", name: newName, spareNoses: newNoseCount, client: client)
            #expect(updateStatus == .badRequest)
            //#expect(updateStatus == .unprocessableContent)
            


        }
    }

    @Test func testFormDecrementNose() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            //let newNoseCount = 18
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            #expect(beforeClown != nil)
            let response = try await client.execute(uri: "/clowns/form/honk/", 
                                     method: .post,
                                     body: ByteBuffer(string: "id=\(knownGoodID)"))

            #expect(response.status == .ok)
            //try await request.decode(as: UpdateRequest.self, context: context)
            //print(String(buffer:response.body))
            // let clown = try await Self.patch(id: knownGoodID, spareNoses: newNoseCount, client: client)
            // #expect(responseClown != nil)
            // #expect(clown!.spareNoses == newNoseCount )
            // #expect(clown!.name == beforeClown?.name )
            // #expect(clown!.spareNoses != beforeClown?.spareNoses)
            // #expect(clown!.id == beforeClown?.id)

            // let retrievedClown = try await Self.get(id: clown!.id, client: client)
            // #expect(clown == retrievedClown)
            // let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
            // #expect(retrievedClown == retrievedOrigIDClown)
        }
    }

    @Test func testUpdateNose() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let newNoseCount = 18
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            let clown = try await Self.patch(id: knownGoodID, spareNoses: newNoseCount, client: client)
            #expect(clown != nil)
            #expect(clown!.spareNoses == newNoseCount )
            #expect(clown!.name == beforeClown?.name )
            #expect(clown!.spareNoses != beforeClown?.spareNoses)
            #expect(clown!.id == beforeClown?.id)

            let retrievedClown = try await Self.get(id: clown!.id, client: client)
            #expect(clown == retrievedClown)
            let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
            #expect(retrievedClown == retrievedOrigIDClown)
        }
    }

    @Test func testUpdateName() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let newName = "Bozo Jr."
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            let clown = try await Self.patch(id: knownGoodID, name:newName, client: client)
            #expect(clown != nil)
            #expect(clown!.name == newName )
            #expect(clown!.name != beforeClown?.name )
            #expect(clown!.spareNoses == beforeClown?.spareNoses)
            #expect(clown!.id == beforeClown?.id)

            let retrievedClown = try await Self.get(id: clown!.id, client: client)
            #expect(clown == retrievedClown)
            let retrievedOrigIDClown = try await Self.get(id: knownGoodID, client: client)
            #expect(retrievedClown == retrievedOrigIDClown)
        }
    }


//        If a DELETE method is successfully applied, the origin server SHOULD
//    send a 202 (Accepted) status code if the action will likely succeed
//    but has not yet been enacted, a 204 (No Content) status code if the
//    action has been enacted and no further information is to be supplied,
//    or a 200 (OK) status code if the action has been enacted and the
//    response message includes a representation describing the status.

//    A payload within a DELETE request message has no defined semantics;
//    sending a payload body on a DELETE request might cause some existing
//    implementations to reject the request.

    //MARK: Test Deletes
    @Test func testDelete() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            #expect(beforeClown != nil)
            let status = try await Self.delete(id: knownGoodID, client: client)
            #expect(status == .ok || status == .noContent)
            try await client.execute(uri: "/clowns/\(knownGoodID)", method: .get) { response in
                #expect(response.status == .notFound)
            }
            try await client.execute(uri: "/clowns/\(knownGoodID)", method: .delete) { response in
                #expect(response.status == .notFound)
            }
        }

    }

    @Test func testFormDelete() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            #expect(beforeClown != nil, "for this test, clown should exist before deleting")

            var status = try await Self.formDelete(id: knownGoodID, name: "hfu5lgh82", client: client)
            #expect(status == .badRequest, "bad name should be badRequest not \(status)") 

            status = try await Self.formDelete(id: knownGoodID, name: beforeClown!.name, client: client)
            #expect(status == .noContent, "successful delete with no payload should be noContent not \(status)")
            
            status = try await Self.delete(id: knownGoodID, client: client)
            #expect(status == .notFound, "clown should be badRequest on second delete, not \(status)")
            
            try await client.execute(uri: "/clowns/\(knownGoodID)", method: .get) { response in
                #expect(response.status == .notFound, "clown should be notFound after being deleted, not \(response.status)")
            }
        }
        

    }
    

    @Test func testDeleteAll() async throws {
        let app = try await buildApplication(TestArguments(), clownStore: clownStore)

        try await app.test(.router) { client in
            let knownGoodID = 4
            let beforeClown = try await Self.get(id: knownGoodID, client: client)
            #expect(beforeClown != nil)
            let status = try await Self.deleteAll(client: client)
            #expect(status == .ok)
            try await client.execute(uri: "/clowns/\(knownGoodID)", method: .get) { response in
                #expect(response.status == .notFound)
            }
            try await client.execute(uri: "/clowns/\(knownGoodID)", method: .delete) { response in
                #expect(response.status == .notFound)
            }

            let deletedClowns = try await Self.list(client: client)
            #expect(deletedClowns.isEmpty)
        }
    }
}