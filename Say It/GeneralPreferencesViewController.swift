//
//  ViewController.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

private func sliderValueToSpeed(_ v: Double) -> Double {
    if v < 10 {
        return 1/40*v + 3/4
    } else if v < 70 {
        return 1/60*v + 5/6
    } else {
        return 1/20*v - 3/2
    }
}

private func speedToSliderValue(_ s: Double) -> Double {
    if s < 0.75 {
        return 40*s - 30
    } else if s < 2 {
        return 60*s - 50
    } else {
        return 20*s + 30
    }
}

private func speedToWPM(_ s: Double) -> Int {
    Int(s * 225)
}

private func wpmToSpeed(_ rate: Int) -> Double {
    Double(rate)/225
}

class GeneralPreferencesViewController: NSViewController, NSSpeechSynthesizerDelegate, NSTextFieldDelegate {
    @IBOutlet var speedSlider: NSSlider!
    @IBOutlet var rateLabel: NSTextField!
    @IBOutlet var testButton: NSButton!
    @IBOutlet var dockCheckbox: NSButton!

    // This constrait is only used to make IB happy at design time. When the
    // code is running, we constrain the bottom of the tick mark labels to be
    // less than the bottom of the superview.
    @IBOutlet var speedSliderBottomConstraint: NSLayoutConstraint!


    var speakerBeginId: UUID!
    var speakerCompletionId: UUID!

    var speedFormatter = NumberFormatter()

    var speaking = false {
        didSet {
            if speaking {
                speedSlider.isEnabled = false
                testButton.title = "Stop"
            } else {
                speedSlider.isEnabled = true
                testButton.title = "Play"
            }
        }
    }

    var speed = 1.0 {
        didSet {
            let rate = speedToWPM(speed)

            let description = "\(speedFormatter.string(from: NSNumber(value: speed)) ?? "?")x (\(rate) WPM)"

            rateLabel.stringValue = description
            speedSlider.toolTip = description

            Defaults.rate = rate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        speedFormatter.minimumFractionDigits = 0
        speedFormatter.maximumFractionDigits = 2

        speed = wpmToSpeed(Defaults.rate)
        speedSlider.doubleValue = speedToSliderValue(speed)

        labelTickMarks()
    }

    func labelTickMarks() {
        speedSliderBottomConstraint.isActive = false

        labelTickMark(1, of: speedSlider, withText: "1x")
        labelTickMark(7, of: speedSlider, withText: "2x")
        labelTickMark(9, of: speedSlider, withText: "3x")
    }

    func labelTickMark(_ i: Int, of slider: NSSlider, withText text: String) {
        guard i < slider.numberOfTickMarks else { return }

        let label = NSTextField(labelWithString: text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 10) // Matches the size of the labels in Energy Saver prefs

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


    @IBAction func updateRate(_ sender: NSSlider) {
        speed = sliderValueToSpeed(sender.doubleValue)

        guard let event = NSApp.currentEvent else {
            return
        }

        if event.type == .leftMouseDown {
            rateLabel.isHidden = false
        } else if event.type == .leftMouseUp {
            rateLabel.isHidden = true
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

