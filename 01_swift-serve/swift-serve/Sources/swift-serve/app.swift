import ArgumentParser
import Hummingbird
import Logging

@main
struct WebServer: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Argument
    var folder: String = "."

    func run() async throws {

        print(folder)

        let logger = Logger(label: "swift-serve")
        let router = Router()
        router.middlewares.add(FileMiddleware(self.folder, searchForIndexHtml: true, logger: logger))
        router.middlewares.add(LogRequestsMiddleware(.info))
        
        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(self.hostname, port: self.port),
                serverName: "swift-serve"
            ),
            logger: logger
        )
        try await app.runService()
    }
}
