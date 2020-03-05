//
//  TranscriptController.swift
//  Say It
//
//  Created by David Albert on 3/5/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class TranscriptController: NSViewController {
    var log: [String]! {
        didSet {
            update()
        }
    }
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func update() {
        textView.string = log.joined(separator: "\n\n")
    }
}
