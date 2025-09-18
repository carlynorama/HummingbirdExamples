import ClownAPI
import OpenAPIRuntime

extension Components.Schemas.Clown {
    /// Maps a `Clown` to a `Components.Schemas.Clown`
    /// This makes it easier to send models to the API
    init(clown: Clown) {
        self.init(id: clown.id, name: clown.name, spareNoses: clown.spareNoses)
    }
}

struct ClownAPIHandler: APIProtocol {
    // func getHello(_ input: ClownAPI.Operations.GetHello.Input) async throws -> ClownAPI.Operations.GetHello.Output {
    //     return .ok(.init(body: .plainText("Hello!")))
    // }


    let repository: ClownCar

    func greet(_ input: Operations.Greet.Input) async throws -> Operations.Greet.Output {
        // 1.
        return .ok(.init(body: .plainText("Hello!")))
    }

    func greetFormally(_ input: Operations.GreetFormally.Input) async throws -> Operations.GreetFormally.Output {
        // 1.
        return .ok(.init(body:
            // 2.
            .json(.init(
                // 3
                message: "Hello, world!"
            ))
        ))
    }

    func testClown(_ input:Operations.TestClown.Input) async throws -> Operations.TestClown.Output {
        let clown = Clown(id: 144214, name:"Polka Dot" , spareNoses: 56)
        //see extension above.
        return .ok(.init(body: .json(.init(clown:clown))))
    }

    func create(_ input:Operations.Create.Input) async throws -> Operations.Create.Output {
        print("CREATING!!!")
        //ClownCreateRequest
        
        let (name, suggestedNoses) = switch input.body {
            case .json(let clownInfo):
                (clownInfo.name, clownInfo.spareNoses)
        }
        print(name, suggestedNoses ?? 0)
        let clown = try await repository.create(name: name, spareNoses: suggestedNoses ?? 5)
        return .ok(.init(body: .json(.init(clown: clown))))
    }

    func list(_ input:Operations.List.Input) async throws -> Operations.List.Output {
        let list = try await self.repository.list().map { Components.Schemas.Clown(clown: $0) }
        return .ok(.init(body: .json(.init(list))))
    }

    func fetchByID(_ input:Operations.FetchByID.Input) async throws -> Operations.FetchByID.Output {
        if let clown = try await repository.get(id: input.path.id) {
            return .ok(.init(body: .json(.init(clown:clown))))
        } else {
            //TODO: should also be JSON. 
            return .notFound(.init(body: .plainText("Was not able to retrieve that clown.")))
        }
    }

    //curl -i -X PATCH localhost:8080/api/v0/clowns/4 -d'{"name":"Joey","spareNoses":78}' -H 'Content-Type: application/json'
    func update(_ input:Operations.Update.Input) async throws -> Operations.Update.Output {
        let id = input.path.id
        let (name, suggestedNoses) = switch input.body {
            case .json(let clownInfo):
                (clownInfo.name, clownInfo.spareNoses)
        }
        if let clown = try await repository.update(id: id, name: name, spareNoses: suggestedNoses) {
            return .ok(.init(body: .json(.init(clown:clown))))
        } else {
            //TODO: should also be JSON. 
            return .badRequest(.init(body: .plainText("Was not able to update the clown.")))

        }
    }

    func delete(_ input: Operations.Delete.Input) async throws -> Operations.Delete.Output {
        let id = input.path.id

        if let clown = try await repository.get(id: input.path.id) {
            if try await self.repository.delete(id: id) {
                return .ok(.init(body: .json(.init(clown:clown))))
            } else {
                //Not exactly correct. 
                return .badRequest(.init(body: .plainText("id unable to be deleted.")))
            }
        } else {
            //perhaps a security leak, but okay. 
            // this is maybe actually debatably a success, in that no more of this clown is true.
            return .badRequest(.init(body: .plainText("id already does not exist.")))
        } 
    }

    func deleteAll(_ input: Operations.DeleteAll.Input) async throws -> Operations.DeleteAll.Output {
        try await self.repository.deleteAll()
        return .ok(.init(body: .json(.init(message: "All deleted!"))))
    }

}
