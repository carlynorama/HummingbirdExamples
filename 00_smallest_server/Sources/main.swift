import Hummingbird
// create router and add a single GET /hello route
let router = Router()
    .get("hello") { request, _ -> String in
        return "Hello"
    }
// create application using router
let app = Application(router: router)
// run hummingbird application
try await app.runService()
