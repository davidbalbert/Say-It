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
    var preferencesWindowController: NSWindowController!
    var transcriptWindowController: NSWindowController!
    var statusItem: NSStatusItem!
    var stopSpeakingShortcut: GlobalKeyboardShortcut!
    var sayItFromClipboardShortcut: GlobalKeyboardShortcut!

    var log: [TranscriptEntry] = [] {
        didSet {
            (transcriptWindowController.contentViewController as! TranscriptViewController).log = log
        }
    }

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

        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        preferencesWindowController = storyboard.instantiateController(identifier: "Preferences")
        transcriptWindowController = storyboard.instantiateController(identifier: "Transcript")

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

        sayItFromClipboardShortcut = GlobalKeyboardShortcut(key: .quote, modifiers: [.command, .control]) { shortcut in
            if self.canSayItFromClipboard() {
                self.sayItFromClipboard(nil)
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
        preferencesWindowController.window?.center()
        preferencesWindowController.showWindow(self)

        return false
    }

    func canSayItFromClipboard() -> Bool {
        guard let items = NSPasteboard.general.pasteboardItems else { return false }
        let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.plain-text")])

        return type != nil
    }

    @IBAction func sayItFromClipboard(_ sender: Any?) {
        var error: NSString?

        sayIt(NSPasteboard.general, userData: nil, error: &error)
    }

    @objc func sayIt(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {

        NSWorkspace.shared.menuBarOwningApplication?.activate()

        guard let items = pboard.pasteboardItems else { return }
        guard let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.plain-text")]) else { return }

        guard let s = items[0].string(forType: type) else { return }

        log.append(TranscriptEntry(date: Date(), text: s.trimmingCharacters(in: .whitespacesAndNewlines)))

        speaker.startSpeaking(s)
    }

    @IBAction func stopSpeaking(_ sender: Any?) {
        speaker.stopSpeaking()

    }

    @IBAction func showPreferences(_ sender: Any) {
        preferencesWindowController.window?.center()
        preferencesWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func showTranscript(_ sender: Any) {
        transcriptWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func orderFrontStandardAboutPanel(_ sender: Any) {
        NSApp.orderFrontStandardAboutPanel(sender)
        NSApp.activate(ignoringOtherApps: true)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(AppDelegate.stopSpeaking(_:)) && !speaker.isSpeaking {
            return false
        } else if menuItem.action == #selector(AppDelegate.sayItFromClipboard(_:)) {
            return canSayItFromClipboard()
        }

        return true
    }
}

