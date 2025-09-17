import ClownAPI
import OpenAPIRuntime

struct APIImplementation: APIProtocol {
    func getHello(_ input: ClownAPI.Operations.GetHello.Input) async throws -> ClownAPI.Operations.GetHello.Output {
        return .ok(.init(body: .plainText("Hello!")))
    }
}
