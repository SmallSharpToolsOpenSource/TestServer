//
//  WebServer.swift
//  TestServer
//
//  Created by Brennan Stehling on 9/4/16.
//  Copyright © 2016 SmallSharpTools LLC. All rights reserved.
//

import Foundation
import Swifter

internal class WebServer {
    let server = HttpServer()
    var isStarted: Bool = false

    internal func prepare() {
        server["/hello"] = { request in
            return .OK(.Html("Hello"))
        }

        server["/data"] = { request in
            return .OK(.Json(["data" : "123"]))
        }
    }

    internal func start() {
        prepare()
        do {
            try server.start(8081)
            isStarted = true
        }
        catch {
            // deal with it
        }
    }

    internal func stop() {
        server.stop()
        isStarted = false
    }

}
