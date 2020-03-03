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
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    @IBOutlet var statusMenu: NSMenu!
    var windowController: NSWindowController!
    var statusItem: NSStatusItem!
    var stopSpeakingShortcut: GlobalKeyboardShortcut!

    @objc var speaker: Speaker

    override init() {
        speaker = Speaker()

        super.init()
        appDelegate = self
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self

        if !Defaults.showDock && NSApp.activationPolicy() != .accessory {
            NSApp.setActivationPolicy(.accessory)
        }

        windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "Preferences")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.menu = statusMenu
        statusItem.button?.image = NSImage(named: "StatusIcon")

        stopSpeakingShortcut = GlobalKeyboardShortcut(key: .quote, modifiers: [.command, .shift]) { shortcut in
            if self.speaker.isSpeaking {
                self.stopSpeaking(nil)
                self.statusItem.button?.highlight(true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.statusItem.button?.highlight(false)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowController.window?.center()
        windowController.showWindow(self)

        return false
    }

    @objc func sayIt(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {

        NSWorkspace.shared.menuBarOwningApplication?.activate()

        guard let items = pboard.pasteboardItems else { return }
        guard let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.text")]) else { return }
        guard let s = items[0].string(forType: type) else { return }

        speaker.startSpeaking(s)
    }

    @IBAction func stopSpeaking(_ sender: Any?) {
        speaker.stopSpeaking()

    }

    @IBAction func showPreferences(_ sender: Any) {
        windowController.window?.center()
        windowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if (menuItem.action == #selector(AppDelegate.stopSpeaking(_:)) && !speaker.isSpeaking) {
            return false
        }

        return true
    }
}

