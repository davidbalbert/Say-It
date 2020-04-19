//
//  ViewController.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController: NSViewController, NSSpeechSynthesizerDelegate, NSTextFieldDelegate {
    @IBOutlet var speedSlider: NSSlider!
    @IBOutlet var testButton: NSButton!
    @IBOutlet var dockCheckbox: NSButton!

    // This constrait is only used to make IB happy at design time. When the
    // code is running, we constrain the bottom of the tick mark labels to be
    // less than the bottom of the superview.
    @IBOutlet var speedSliderBottomConstraint: NSLayoutConstraint!


    var speakerBeginId: UUID!
    var speakerCompletionId: UUID!

    var speaking = false {
        didSet {
            if speaking {
                speedSlider.isEnabled = false
                testButton.title = "Stop"
            } else {
                speedSlider.isEnabled = true
                testButton.title = "Test"
            }
        }
    }

    var rate: Int = Defaults.rate

    override func viewDidLoad() {
        super.viewDidLoad()

        labelTickMarks()
    }

    func labelTickMarks() {
        speedSliderBottomConstraint.isActive = false

        labelTickMark(0, of: speedSlider, withText: "0.5x")
        labelTickMark(1, of: speedSlider, withText: "1x")
        labelTickMark(3, of: speedSlider, withText: "2x")
        labelTickMark(5, of: speedSlider, withText: "3x")
    }

    func labelTickMark(_ i: Int, of slider: NSSlider, withText text: String) {
        guard i < slider.numberOfTickMarks else { return }

        let label = NSTextField(labelWithString: text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.controlSize = .mini
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini))
        label.alignment = .center

        slider.superview?.addSubview(label)

        let r = slider.rectOfTickMark(at: i)

        label.centerXAnchor.constraint(equalTo: slider.leadingAnchor, constant: r.minX).isActive = true
        label.topAnchor.constraint(equalTo: slider.topAnchor, constant: r.minY+r.height+3).isActive = true
        label.superview?.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor).isActive = true
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

