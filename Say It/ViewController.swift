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

    func voiceNames() -> [String] {
        return NSSpeechSynthesizer.availableVoices.map { voice in
            NSSpeechSynthesizer.attributes(forVoice: voice)[.name] as! String
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        voicesMenu.removeAllItems()
        voicesMenu.addItems(withTitles: voiceNames())
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sayIt(_ sender: NSButton) {
        let synth = NSSpeechSynthesizer()
        synth.delegate = self
        sayItButton.isEnabled = false

        synth.startSpeaking(textField.stringValue)
    }

    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        sayItButton.isEnabled = true
    }
}

