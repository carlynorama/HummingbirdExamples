#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Hummingbird

public struct ClownController: Sendable {
    // clown repository
    let repository: ClownCar

    // return clown endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
            .get(":id", use: get)
            .get(use: list)
            .get(use: list)
            .post(use: create)
            .patch(":id", use: update)
            .delete(":id", use: delete)
            .delete(use: deleteAll)
    }

    /// Get clown endpoint
    @Sendable func get(request: Request, context: some RequestContext) async throws -> Clown? {
        let id = try context.parameters.require("id", as: Int.self)
        return try await self.repository.get(id: id)
    }

    /// Get list of clowns endpoint
    @Sendable func list(request: Request, context: some RequestContext) async throws -> [Clown] {
        return try await self.repository.list()
    }

    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }

    /// Create clown endpoint
    @Sendable func create(request: Request, context: some RequestContext) async throws
        -> EditedResponse<Clown>
    {
        let request = try await request.decode(as: CreateRequest.self, context: context)

        //TODO: THIS IS BAD!!!!
        let clown = try await self.repository.create(
            title: request.title, order: request.order)

        return EditedResponse(status: .created, response: clown)
    }

    struct UpdateRequest: Decodable {
        let title: String?
        let order: Int?
        let completed: Bool?
    }
    /// Update clown endpoint
    @Sendable func update(request: Request, context: some RequestContext) async throws -> Clown? {
        let id = try context.parameters.require("id", as: UUID.self)
        let request = try await request.decode(as: UpdateRequest.self, context: context)
        guard
            let clown = try await self.repository.update(
                id: id,
                title: request.title,
                order: request.order,
                completed: request.completed
            )
        else {
            throw HTTPError(.badRequest)
        }
        return clown
    }

    /// Delete clown endpoint
    @Sendable func delete(request: Request, context: some RequestContext) async throws
        -> HTTPResponse.Status
    {
        let id = try context.parameters.require("id", as: UUID.self)
        if try await self.repository.delete(id: id) {
            return .ok
        } else {
            return .badRequest
        }
    }

    /// Delete all clowns endpoint
    @Sendable func deleteAll(request: Request, context: some RequestContext) async throws
        -> HTTPResponse.Status
    {
        try await self.repository.deleteAll()
        return .ok
    }

}
