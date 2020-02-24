//
//  ViewController.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController: NSViewController, NSSpeechSynthesizerDelegate {

    @IBOutlet var textField: NSTextField!
    @IBOutlet var sayItButton: NSButton!
    @IBOutlet var sayItFromClipboardButton: NSButton!
    @IBOutlet var stopButton: NSButton!

    @IBOutlet var rateSlider: NSSlider!
    @IBOutlet var rateTextField: NSTextField!

    var speakerBeginId: UUID!
    var speakerCompletionId: UUID!

    let minRate: Int = 100
    let maxRate: Int = 800

    var speaking = false {
        didSet {
            if speaking {
                textField.isEnabled = false
                sayItButton.isEnabled = false
                sayItFromClipboardButton.isEnabled = false
                rateSlider.isEnabled = false
                rateTextField.isEnabled = false

                stopButton.isEnabled = true
            } else {
                textField.isEnabled = true
                sayItButton.isEnabled = true
                sayItFromClipboardButton.isEnabled = true
                rateSlider.isEnabled = true
                rateTextField.isEnabled = true

                stopButton.isEnabled = false
            }
        }
    }

    var rate: Int! {
        didSet {
            if rate < minRate {
                rate = minRate
            } else if rate > maxRate {
                rate = maxRate
            }

            rateSlider.intValue = Int32(rate)
            rateTextField.intValue = Int32(rate)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rate = appDelegate.speaker.rate
        rateSlider.minValue = Double(minRate)
        rateSlider.maxValue = Double(maxRate)
    }

    override func viewWillAppear() {
        speakerBeginId = appDelegate.speaker.addBeginHandler { [weak self] in
            self?.speaking = true
        }

        speakerCompletionId = appDelegate.speaker.addCompletionHandler { [weak self] in
            self?.speaking = false
        }
    }

    override func viewWillDisappear() {
        appDelegate.speaker.removeBeginHandler(speakerBeginId)
        appDelegate.speaker.removeCompletionHandler(speakerCompletionId)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func sayIt(_ sender: NSButton) {
        appDelegate.speaker.startSpeaking(textField.stringValue)
    }

    @IBAction func sayItFromClipboard(_ sender: NSButton) {
        guard let text = NSPasteboard.general.string(forType: .string) else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "No text in the clipboard"
            alert.informativeText = "There's no text in the clipboard, so there's nothing to say. Copy some text and try again."
            alert.alertStyle = .warning
            alert.beginSheetModal(for: view.window!, completionHandler: nil)
            return
        }

        appDelegate.speaker.startSpeaking(text)
    }

    @IBAction func updateRate(_ sender: NSControl) {
        rate = Int(sender.intValue)

        guard let event = NSApp.currentEvent else { return }

        if event.type != .leftMouseDown && event.type != .leftMouseDragged {
            Defaults.rate = rate
        }
    }

    @IBAction func stopSpeaking(_ sender: Any) {
        appDelegate.speaker.stopSpeaking()
    }

    @IBAction func toggleDockIcon(_ sender: Any) {
        if NSApp.activationPolicy() == .regular {
            Defaults.showDock = false
            NSApp.setActivationPolicy(.accessory)
        } else {
            Defaults.showDock = true
            NSApp.setActivationPolicy(.regular)
        }
    }
}

