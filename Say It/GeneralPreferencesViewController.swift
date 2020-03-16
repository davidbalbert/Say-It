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
    @IBOutlet var rateSlider: NSSlider!
    @IBOutlet var rateTextField: NSTextField!
    @IBOutlet var testButton: NSButton!
    @IBOutlet var dockCheckbox: NSButton!

    var speakerBeginId: UUID!
    var speakerCompletionId: UUID!

    let minRate: Int = 100
    let maxRate: Int = 800

    var speaking = false {
        didSet {
            if speaking {
                textField.isEnabled = false
                rateSlider.isEnabled = false
                rateTextField.isEnabled = false
                testButton.title = "Stop"
                testButton.action = #selector(stopSpeaking(_:))
            } else {
                textField.isEnabled = true
                rateSlider.isEnabled = true
                rateTextField.isEnabled = true
                testButton.title = "Test"
                testButton.action = #selector(speakTextfieldContents(_:))

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

        dockCheckbox.state = Defaults.showDock ? .on : .off
    }

    override func viewWillDisappear() {
        appDelegate.speaker.removeBeginHandler(speakerBeginId)
        appDelegate.speaker.removeCompletionHandler(speakerCompletionId)
    }

    @IBAction func updateRate(_ sender: NSControl) {
        rate = Int(sender.intValue)

        guard let event = NSApp.currentEvent else { return }

        if event.type != .leftMouseDown && event.type != .leftMouseDragged {
            Defaults.rate = rate
        }
    }

    @IBAction func speakTextfieldContents(_ sender: NSButton) {
        appDelegate.speaker.startSpeaking(textField.stringValue)
    }

    @IBAction func stopSpeaking(_ sender: NSButton) {
        appDelegate.speaker.stopSpeaking()
    }

    @IBAction func toggleDockIcon(_ sender: Any) {
        if NSApp.activationPolicy() == .regular {
            Defaults.showDock = false
            NSApp.setActivationPolicy(.accessory)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            Defaults.showDock = true
            NSApp.setActivationPolicy(.regular)
        }
    }
}

