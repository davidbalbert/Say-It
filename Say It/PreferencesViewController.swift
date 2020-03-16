//
//  PreferencesController.swift
//  Say It
//
//  Created by David Albert on 3/2/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        setWindowTitle()
    }

    func setWindowTitle() {
        view.window?.title = title ?? "Preferences"
    }
}
