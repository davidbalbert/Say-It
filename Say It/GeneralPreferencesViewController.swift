//
//  ViewController.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController: NSViewController, NSSpeechSynthesizerDelegate, NSTextFieldDelegate {
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
                rateSlider.isEnabled = false
                rateTextField.isEnabled = false
                testButton.title = "Stop"
            } else {
                rateSlider.isEnabled = true
                rateTextField.isEnabled = true
                testButton.title = "Test"

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

            rateSlider.integerValue = rate
            rateTextField.objectValue = rate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rate = appDelegate.speaker.rate
        rateSlider.minValue = Double(minRate)
        rateSlider.maxValue = Double(maxRate)

//        let formatter = WPMFormatter()
//        rateTextField.formatter = formatter
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        speakerBeginId = appDelegate.speaker.addBeginHandler { [weak self] in
            self?.speaking = true
        }

        speakerCompletionId = appDelegate.speaker.addCompletionHandler { [weak self] in
            self?.speaking = false
        }

        dockCheckbox.state = Defaults.showDock ? .on : .off
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        appDelegate.speaker.removeBeginHandler(speakerBeginId)
        appDelegate.speaker.removeCompletionHandler(speakerCompletionId)
    }

    @IBAction func updateRate(_ sender: NSControl) {
        rate = sender.integerValue
        Defaults.rate = rate
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        print("what")
        // Async call is necessary to make the text field actually resign first respodner.
        // Not sure why. See more: https://forums.developer.apple.com/thread/104773
        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(nil)
        }
    }

    @IBAction func testRate(_ sender: NSButton) {
        if !speaking {
            appDelegate.speaker.startSpeaking("Hello, I'm your computer")
        } else {
            appDelegate.speaker.stopSpeaking()
        }
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

