

import Hummingbird
// create router and add a single GET /hello route

//ADDING A CONFIGURATION IS REQUIRED TO MAKE _CONTAINER_ WORK
let hostname: String = "0.0.0.0"
let port: Int = 8080
let configuration: ApplicationConfiguration = .init(
    address: .hostname(hostname, port: port),
    serverName: "SmallestServer"
)

let router = Router().get { req, context in
    return "Hello, Swift!"
}

// create application using router
let app = Application(router: router, configuration:configuration)
// run hummingbird application
try await app.runService()