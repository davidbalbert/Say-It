//
//  TranscriptDetailViewController.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class TranscriptDetailViewController: NSViewController {
    @IBOutlet var textView: NSTextView!

    var text: String = "" {
        didSet {
            textView.string = text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
