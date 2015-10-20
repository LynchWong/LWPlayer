//
//  HTTPStreamingServer.swift
//  LWPlayer
//
//  Created by Lynch Wong on 10/19/15.
//  Copyright © 2015 Lynch. All rights reserved.
//

import UIKit

let HTTPStreamingServerSingleton = HTTPStreamingServer()

class HTTPStreamingServer: NSObject {
    
    var httpServer: HTTPServer!
    
    class var sharedInstance: HTTPStreamingServer {
        get {
            return HTTPStreamingServerSingleton
        }
    }
    
    override init() {
        super.init()
        initialize()
    }
    
    func initialize() {
        httpServer = HTTPServer()
        httpServer.setType("_http._tcp.")
        httpServer.setPort(12345)
        let webPath = NSBundle.mainBundle().resourcePath?.stringByAppendingString("/web")
        httpServer.setDocumentRoot(webPath)
    }
    
    func start() {
        do {
            try httpServer.start()
            print("Started HTTP Server on port \(httpServer.listeningPort())")
        } catch {
            print("Error starting HTTP Server")
        }
    }
    
    func stop() {
        httpServer.stop()
    }

}
