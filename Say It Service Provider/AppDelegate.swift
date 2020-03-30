//
//  AppDelegate.swift
//  Say It Service Provider
//
//  Created by David Albert on 3/29/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var directConnection: NSXPCConnection?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if appIsRunning() {
            setupXPC()
        } else {
            let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "is.dave.Say-It")!
            let config = NSWorkspace.OpenConfiguration()

            NSWorkspace.shared.openApplication(at: url, configuration: config) { runningApplication, error in
                // Wait a bit before setting up XPC to make sure the Helper is running
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.setupXPC()
                }
            }
        }
    }

    func appIsRunning() -> Bool {
        return NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == "is.dave.Say-It" } != nil
    }

    func setupXPC() {
        let helperConnection = NSXPCConnection(machServiceName: "is.dave.Say-It-Helper", options: [])
        helperConnection.remoteObjectInterface = NSXPCInterface(with: RendezvousPoint.self)
        helperConnection.resume()

        let service = helperConnection.remoteObjectProxyWithErrorHandler { error in
            NSLog("xxxx Received error in ServiceProvider: \(error.localizedDescription) \(error)")
        } as! RendezvousPoint

        NSLog("xxxx service provider: send register service provider")
        service.registerServiceProvider { endpoint in
            DispatchQueue.main.async {
                NSLog("xxxx service provider: registered")
                let directConnection = NSXPCConnection(listenerEndpoint: endpoint)
                directConnection.remoteObjectInterface = NSXPCInterface(with: SpeakerService.self)
                directConnection.resume()

                // If the main app quits, quit the service provider.
                directConnection.interruptionHandler = {
                    NSApp.terminate(self)
                }

                self.directConnection = directConnection

                NSApp.servicesProvider = self
            }
        }
    }


    @objc func startSpeaking(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {

        guard let items = pboard.pasteboardItems else { return }
        guard let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.plain-text")]) else { return }

        guard let s = items[0].string(forType: type) else { return }

        guard let directConnection = directConnection else {
            NSLog("xxxx service provider: no direct connection")
            return
        }

        let service = directConnection.remoteObjectProxyWithErrorHandler { error in
            NSLog("xxxx Received error in ServiceProvider (direct connection): \(error.localizedDescription) \(error)")
        } as! SpeakerService

        NSLog("xxxx service provider: send text to app \(service)")
        service.startSpeakingFromServiceProvider(s)
    }
}

