//
//  PreferencesWindowController.swift
//  Say It
//
//  Created by David Albert on 3/2/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

        (contentViewController as! PreferencesTabViewController).setWindowTitle()
    }

}
