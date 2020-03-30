//
//  AppDelegate.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa
import ServiceManagement

var appDelegate: AppDelegate!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation, NSXPCListenerDelegate, SpeakerService {
    @IBOutlet var statusMenuController: StatusMenuController!
    var preferencesWindowController: NSWindowController!
    var transcriptWindowController: NSWindowController!
    var statusItem: NSStatusItem!
    var stopSpeakingShortcut: GlobalKeyboardShortcut!
    var sayItFromClipboardShortcut: GlobalKeyboardShortcut!
    var speaker = Speaker()

    var listener: NSXPCListener! // TODO: switch this to let and initialize it on construction

    var log: [TranscriptEntry] = [] {
        didSet {
            (transcriptWindowController.contentViewController as! TranscriptViewController).log = log
        }
    }

    override init() {
        super.init()
        appDelegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !Defaults.showDock && NSApp.activationPolicy() != .accessory {
            NSApp.setActivationPolicy(.accessory)
        }

        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        preferencesWindowController = storyboard.instantiateController(identifier: "Preferences")
        transcriptWindowController = storyboard.instantiateController(identifier: "Transcript")

        statusMenuController.registerCallbacks(speaker)

        stopSpeakingShortcut = GlobalKeyboardShortcut(key: .quote, modifiers: [.command, .shift]) { [weak self] shortcut in
            guard let self = self else {
                return
            }

            if self.speaker.isSpeaking {
                self.stopSpeaking(nil)
                self.statusMenuController.highlightMenu()
            }
        }

        sayItFromClipboardShortcut = GlobalKeyboardShortcut(key: .quote, modifiers: [.command, .control]) { [weak self] shortcut in
            guard let self = self else {
                return
            }

            if self.canStartSpeakingFromClipboard() {
                self.startSpeakingFromClipboard(nil)
                self.statusMenuController.highlightMenu()
            }
        }

        guard SMLoginItemSetEnabled("is.dave.Say-It-Helper" as CFString, true) else {
            NSLog("xxxx Couldn't enable login item")
            return
        }

        setupXPC()

    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("Terminate")
        SMLoginItemSetEnabled("is.dave.Say-It-Helper" as CFString, false)
    }

    func setupXPC() {
        let connection = NSXPCConnection(machServiceName: "is.dave.Say-It-Helper", options: [])
        connection.remoteObjectInterface = NSXPCInterface(with: RendezvousPoint.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Received XPC error in app: \(error.localizedDescription) \(error)")
        } as! RendezvousPoint

        listener = NSXPCListener.anonymous()
        listener.delegate = self
        listener.resume()

        NSLog("xxxx Send register app")
        service.registerApp(endpoint: listener.endpoint)

        connection.interruptionHandler = {
            NSLog("xxxx XPC interrupt, helper probably restated, re-registering app")
            service.registerApp(endpoint: self.listener.endpoint)
        }
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        NSLog("xxxx app: new connection")

        newConnection.exportedInterface = NSXPCInterface(with: SpeakerService.self)
        newConnection.exportedObject = self
        newConnection.resume()

        return true
    }

    func canStartSpeakingFromClipboard() -> Bool {
        guard let items = NSPasteboard.general.pasteboardItems else { return false }
        let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.plain-text")])

        return type != nil
    }

    @IBAction func startSpeakingFromClipboard(_ sender: Any?) {
        guard let items = NSPasteboard.general.pasteboardItems else { return }
        guard let type = items[0].availableType(from: [NSPasteboard.PasteboardType(rawValue: "public.plain-text")]) else { return }

        guard let s = items[0].string(forType: type) else { return }

        startSpeaking(s)
    }

    func startSpeakingFromServiceProvider(_ s: String) {
        DispatchQueue.main.async {
            self.startSpeaking(s)
        }
    }

    func startSpeaking(_ s: String) {
        NSLog("xxxx app: start speaking")

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
        if menuItem.action == #selector(stopSpeaking(_:)) && !speaker.isSpeaking {
            return false
        } else if menuItem.action == #selector(startSpeakingFromClipboard(_:)) {
            return canStartSpeakingFromClipboard()
        }

        return true
    }
}

