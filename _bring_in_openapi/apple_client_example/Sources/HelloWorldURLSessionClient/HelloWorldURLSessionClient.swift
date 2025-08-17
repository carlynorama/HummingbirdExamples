import Foundation
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import OpenAPIRuntime
import OpenAPIURLSession

@main struct HelloWorldURLSessionClient {
    static func main() async throws {
        let client = Client(
            serverURL: URL(string: "http://localhost:8080/api")!, transport: URLSessionTransport())
        let response = try await client.getGreeting(query: .init(name: "CLI"))
        
        
        //THIS
        print(try response.ok.body.json.message)

        //IS THE SHORT FORM OF THIS:
        switch response {
        case .ok(let okResponse):
            //print(okResponse)
            switch okResponse.body {
            case .json(let greeting):
                print(greeting.message)
            }
        case .undocumented(let statusCode, _):
            print("🥺 undocumented response: \(statusCode)")
        //second param: print(y) //"Undocumented Payload"
        }
    }
}
