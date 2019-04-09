//
//  AppDelegate.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

var appDelegate: AppDelegate!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var speaker: Speaker!

    override init() {
        super.init()

        speaker = Speaker()

        appDelegate = self
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.windows.first?.makeKeyAndOrderFront(self)

        return false
    }

    @objc func sayIt(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {

        guard let s = pboard.string(forType: .string) else { return }

        speaker.startSpeaking(s)
    }
}

