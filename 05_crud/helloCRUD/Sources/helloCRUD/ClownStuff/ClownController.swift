import Hummingbird

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

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
      .patch("{id}/honk", use: noseDecrement)
      .delete(":id", use: delete)
      .delete(use: deleteAll)
    return routes
  }

  // CREATE

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

  // READ

  /// Get clown endpoint
  @Sendable func get(request: Request, context: some RequestContext) async throws -> Clown? {
    let id = try context.parameters.require("id", as: Int.self)
    do {
      return try await self.repository.get(id: id)
    }
  }

  /// Get list of clowns endpoint
  @Sendable func list(request: Request, context: some RequestContext) async throws -> [Clown] {
    return try await self.repository.list()
  }

  // UPDATE

  struct UpdateRequest: Decodable {
    let name: String?
    let spareNoses: Int?
  }
  /// Update clown endpoint
  @Sendable func update(request: Request, context: some RequestContext) async throws -> Clown? {
    let id = try context.parameters.require("id", as: Int.self)
    let requestValue = try await request.decode(as: UpdateRequest.self, context: context)
    guard
      let clown = try await self.repository.update(
        id: id,
        name: requestValue.name,
        spareNoses: requestValue.spareNoses
      )
    else {
      throw HTTPError(.badRequest, message: "repository did not update clown")
    }
    return clown
  }

  struct HonkRequest: Decodable {
    let id: Int
  }

  @Sendable func noseDecrement(request: Request, context: some RequestContext) async throws
    -> Clown?
  {
    let honkRequestID = try context.parameters.require("id", as: Int.self)
    if let beforeClown = try await self.repository.get(id: honkRequestID) {
      return try await self.repository.update(
        id: honkRequestID, name: nil, spareNoses: beforeClown.spareNoses - 1)
    }
    return nil
  }

  // DELETE

  /// Delete clown endpoint
  @Sendable func delete(request: Request, context: some RequestContext) async throws
    -> HTTPResponse.Status
  {
    let id = try context.parameters.require("id", as: Int.self)
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
