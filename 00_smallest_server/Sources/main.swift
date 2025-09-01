// import Hummingbird
// // create router and add a single GET /hello route
// let router = Router()
//     .get("hello") { request, _ -> String in
//         return "Hello"
//     }
// // create application using router
// let app = Application(router: router)
// // run hummingbird application
// try await app.runService()

// Things tried to track down the issue: 
// - Add / route? [NO]
// - Add something with a response body? [NO]
// - Change from main.swift to App.swift @main { static main() } [NO]
// - Moved HelloServer Source into this package's source. [YES!!]
//     - remove / route [not it]
//     - remove response body [not it]
//     - remove specialized context [not it]
//     - remove logging [not it]
//     - remove Foundation [not it]
//     - remove separate router call [not it]
//     - fold build app builder back into App.swift [not it]
//     - remove configuration [YES THAT'S IT! ]
// - Add Argument Parser? 



import Hummingbird
// create router and add a single GET /hello route

//ADDING A CONFIGURATION REQUIRED TO MAKE _CONTAINER_ WORK
//TODO: Why?
let hostname: String = "0.0.0.0"
let port: Int = 8080
let configuration: ApplicationConfiguration = .init(
    address: .hostname(hostname, port: port),
    serverName: "SmallestServer"
)

let router = Router()
    .get("hello") { request, _ -> String in
        return "Hello"
    }
// create application using router
let app = Application(router: router, configuration:configuration)
// run hummingbird application
try await app.runService()
