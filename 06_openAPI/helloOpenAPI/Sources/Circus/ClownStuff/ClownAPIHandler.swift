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
    let repository: ClownCar

    func greet(_ input: Operations.Greet.Input) async throws -> Operations.Greet.Output {
        //return .ok(.init(body: .plainText("Hello!")))
        let message = "Hello!"
        let httpBody = OpenAPIRuntime.HTTPBody(message.utf8)
        let OkBody = Operations.Greet.Output.Ok.Body.plainText(httpBody)
        let greetOk = Operations.Greet.Output.Ok(body: OkBody)
        let greetOutput = Operations.Greet.Output.ok(greetOk)
        return greetOutput
    }

    func greetFormally(_ input: Operations.GreetFormally.Input) async throws -> Operations.GreetFormally.Output {
        let jsonPayload = Operations.GreetFormally.Output.Ok.Body.JsonPayload(message: "Hello, world!")
        let greetFormallyOkBody = Operations.GreetFormally.Output.Ok.Body.json(jsonPayload)
        let greetFormallyOk = Operations.GreetFormally.Output.Ok(body: greetFormallyOkBody)
        let greetFormallyOutput = Operations.GreetFormally.Output.ok(greetFormallyOk)
        return greetFormallyOutput

        // return .ok(.init(body:
        //     .json(.init(
        //         message: "Hello, world!"
        //     ))
        // ))
    }

    // func greetFormally(_ input: Operations.GreetFormally.Input) async throws -> Operations.GreetFormally.Output {
    //     //undocumented(statusCode: Swift.Int, OpenAPIRuntime.UndocumentedPayload)
    //     let message = "Not right now thanks."
    //     let httpBody = OpenAPIRuntime.HTTPBody(message.utf8)
    //     return .undocumented(statusCode: 418, .init(headerFields: .init(dictionaryLiteral: []), body: httpBody))
    // }

    func testClown(_ input:Operations.TestClown.Input) async throws -> Operations.TestClown.Output {
        let clown = Clown(id: 144214, name:"Polka Dot" , spareNoses: 56)
        //see extension above.
        let myClown = Components.Schemas.Clown(clown: clown)
        return .ok(.init(body: .json(myClown)))
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
