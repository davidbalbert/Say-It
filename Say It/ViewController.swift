//
//  ViewController.swift
//  Say It
//
//  Created by David Albert on 3/13/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSSpeechSynthesizerDelegate {

    @IBOutlet var voicesMenu: NSPopUpButton!
    @IBOutlet var textField: NSTextField!
    @IBOutlet var sayItButton: NSButton!
    @IBOutlet var sayItFromClipboardButton: NSButton!
    @IBOutlet var stopButton: NSButton!

    @IBOutlet var rateSlider: NSSlider!
    @IBOutlet var rateTextField: NSTextField!

    let synth = NSSpeechSynthesizer()

    let minRate: Int32 = 100
    let maxRate: Int32 = 800

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

    var rate: Int32! {
        didSet {
            if rate < minRate {
                rate = minRate
            } else if rate > maxRate {
                rate = maxRate
            }

            rateSlider.intValue = rate
            rateTextField.intValue = rate
            synth.rate = Float(rate)
        }
    }

    func voiceNames() -> [String] {
        return NSSpeechSynthesizer.availableVoices.map { voice in
            NSSpeechSynthesizer.attributes(forVoice: voice)[.name] as! String
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        voicesMenu.removeAllItems()
        voicesMenu.addItems(withTitles: voiceNames())

        synth.delegate = self

        rate = Int32(synth.rate)
        rateSlider.minValue = Double(minRate)
        rateSlider.maxValue = Double(maxRate)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sayIt(_ sender: NSButton) {
        speaking = true
        synth.startSpeaking(textField.stringValue)
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

        speaking = true
        synth.startSpeaking(text)
    }

    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        speaking = false
    }

    @IBAction func updateRate(_ sender: NSControl) {
        rate = sender.intValue
    }

    @IBAction func stopSpeaking(_ sender: Any) {
        synth.stopSpeaking()
    }
}

