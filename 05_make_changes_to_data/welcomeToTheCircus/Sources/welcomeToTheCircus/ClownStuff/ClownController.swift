import Hummingbird
import Foundation


public struct ClownController:Sendable {
        // Todo repository
    let repository: ClownCar

    // return todo endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
        .get(":id", use: get)
        .get(use: list)
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

}