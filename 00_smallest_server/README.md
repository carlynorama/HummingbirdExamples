# Smallest Server


The actual simplest main.swift file would be what's on the Hummingbird homepage:

```Swift
import Hummingbird

let router = Router().get { req, context in
    return "Hello, Swift!"
}
let app = Application(router: router)
try await app.runService()
```

It works perfectly with `build run`, starting a server at 127.0.0.1:8080 which returns "Hello, Swift!" no matter the route.

But since so many servers are meant to work with containers my file looks like: 

```Swift
import Hummingbird
// create router and add a single GET /hello route

//ADDING A CONFIGURATION IS REQUIRED TO MAKE _CONTAINER_ WORK 
//LOCALLY.
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
```

This will let the app server listen on all addresses available to it. Depending on one's setup `host.containers.internal` might work as well. 
	

More discussion: 
- https://www.whynotestflight.com/excuses/podman-how-do-i-deploy-a-hummingbird-app-server/
- https://stackoverflow.com/a/57755490
- https://docs.docker.com/desktop/features/networking/#i-want-to-connect-from-a-container-to-a-service-on-the-host
- https://stackoverflow.com/questions/76488821/access-host-service-both-using-docker-and-using-podman/79131027#79131027

