//
//  AppDelegate.swift
//  Say It Helper
//
//  Created by David Albert on 3/29/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSXPCListenerDelegate, RendezvousPoint {
    let listener = NSXPCListener(machServiceName: Bundle.main.bundleIdentifier!)
    var endpoint: NSXPCListenerEndpoint?
    var pendingServiceProviderCallback: ((NSXPCListenerEndpoint) -> Void)?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        listener.delegate = self
        listener.resume()
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: RendezvousPoint.self)
        newConnection.exportedObject = self
        newConnection.resume()

        return true
    }

    func registerApp(endpoint: NSXPCListenerEndpoint) {
        NSLog("xxxx helper: register app")

        self.endpoint = endpoint

        if let reply = pendingServiceProviderCallback {
            reply(endpoint)
            self.pendingServiceProviderCallback = nil
        }
    }

    func registerServiceProvider(withReply reply: @escaping (NSXPCListenerEndpoint) -> Void) {
        NSLog("xxxx helper: register service provider")

        if let endpoint = endpoint {
            reply(endpoint)
        } else {
            pendingServiceProviderCallback = reply
        }
    }
}

