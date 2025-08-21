#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Hummingbird

    //TODO: Are these the correct responses? 
    //https://en.wikipedia.org/wiki/OpenAPI_Specification

public struct ClownController: Sendable {
    // clown repository
    let repository: ClownCar

    // return clown endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        let routes = RouteCollection(context: AppRequestContext.self)
         //routes.group(context: FlexContext.self)
         routes.group()
            .get(":id", use: get)
            .get(use: list)
            .post(use: create)
            .patch(":id", use: update)
            .delete(":id", use: delete)
            .delete(use: deleteAll)
            //Swift is not a white space based language! only can pull off ONE subgroup.
            //Any and all routes placed after the group belong to the group.
        routes.group()
            .group("form")
                .post("join", use: formCreate)
                //TODO should this be delete? the form data is being patched.
                .post("leave", use: formDeleteWithNameVerify)
                .post("honk", use: formNoseDecrement)

        return routes
    }

    /// Get clown endpoint
    @Sendable func get(request: Request, context: some RequestContext) async throws -> OptionalHandler<Clown> {
        let id = try context.parameters.require("id", as: Int.self)
        let clown = try await self.repository.get(id: id)
        return OptionalHandler(value:clown)
        //return try await self.repository.get(id: id)
    }

    /// Get list of clowns endpoint
    @Sendable func list(request: Request, context: some RequestContext) async throws -> [Clown] {
        return try await self.repository.list()
    }

    struct CreateRequest: Decodable {
        let name: String
        let spareNoses: Int?
    }

    /// Create clown endpoint
    @Sendable func create(request: Request, context: some RequestContext) async throws
        -> EditedResponse<Clown>
    {
        let request = try await request.decode(as: CreateRequest.self, context: context)

        let clown = try await self.repository.create(
            name: request.name, spareNoses: request.spareNoses ?? 10)
        return EditedResponse(status: .created, response: clown)
    }

    @Sendable func formCreate(request: Request, context: some RequestContext) async throws
        -> EditedResponse<Clown>
    {
        let request = try await URLEncodedFormDecoder().decode(CreateRequest.self, from: request, context: context)
        let clown = try await self.repository.create(
            name: request.name, spareNoses: request.spareNoses ?? 10)
        return EditedResponse(status: .created, response: clown)
    }

    struct UpdateRequest: Decodable {
        let name: String?
        let spareNoses: Int?
    }
    /// Update clown endpoint
    @Sendable func update(request: Request, context: some RequestContext) async throws -> Clown {
        let id = try context.parameters.require("id", as: Int.self)
        let requestValue = try await request.decode(as: UpdateRequest.self, context: context)
        guard
            let clown = try await self.repository.update(
                id: id,
                name: requestValue.name,
                spareNoses: requestValue.spareNoses
            )
        else {
            throw HTTPError(.notFound)
        }
        return clown
    }

    struct HonkRequest:Decodable {
        let id:Int
    }

    @Sendable func formNoseDecrement(request: Request, context: some RequestContext) async throws
        -> OptionalHandler<Clown>
    {   
        let request = try await URLEncodedFormDecoder().decode(HonkRequest.self, from: request, context: context)
                //let id = try context.parameters.require("id", as: Int.self)
        if let beforeClown = try await self.repository.get(id:request.id) {
            return OptionalHandler<Clown>(value:try await self.repository.update(id: request.id, name: nil, spareNoses: beforeClown.spareNoses - 1))
        } else {
            
            return  OptionalHandler<Clown>(value: nil)
        }

    }

    /// Delete clown endpoint
    @Sendable func delete(request: Request, context: some RequestContext) async throws
        -> HTTPResponse.Status
    {
        let id = try context.parameters.require("id", as: Int.self)
        let deleteResult = try await self.repository.delete(id: id)
        switch deleteResult {
            case 1: return .noContent //success, no clown in response body. 
            case 0: return .badRequest
            case nil: return .notFound // or should this be .notFound? put it in the body.
            default: throw ClownError.undefinedResult
        }
    }

    struct DeleteRequest: Decodable {
        let id: Int
        let name: String
    }


    @Sendable func formDeleteWithNameVerify(request: Request, context: some RequestContext) async throws
        -> HTTPResponse.Status
    {
        let request = try await URLEncodedFormDecoder().decode(DeleteRequest.self, from: request, context: context)
                //let id = try context.parameters.require("id", as: Int.self)
        if let record = try await self.repository.get(id:request.id) {
                
                if record.name == request.name {
                    let deleteResult:Int? = try await self.repository.delete(id: request.id)
                    switch deleteResult {
                        case 1: return .noContent //success, no clown in response body. 
                        case 0: return .badRequest
                        case nil: return .notFound
                        default: throw ClownError.undefinedResult
                    }
                } else {
                        return .badRequest
                }
            }
        return .notFound
    }


    

    /// Delete all clowns endpoint
    @Sendable func deleteAll(request: Request, context: some RequestContext) async throws
        -> HTTPResponse.Status
    {
        try await self.repository.deleteAll()
        return .ok
    }

}
