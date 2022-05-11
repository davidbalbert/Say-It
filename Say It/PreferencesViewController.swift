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
        // Super.viewDidLoad() selects tabIndex 0, which will overwrite
        // our saved preference. Load the preference, then call super,
        // and finally, restore the preference.
        let identifier = Defaults.selectedPreferenceTabIdentifier

        super.viewDidLoad()


        let i = tabView.indexOfTabViewItem(withIdentifier: identifier as Any)
        if i != NSNotFound {
            selectedTabViewItemIndex = i
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        guard let window = view.window, let view = tabView.selectedTabViewItem?.view else {
            return
        }

        guard let frame = frame(of: window, for: view) else {
            return
        }

        window.setFrame(frame, display: false)
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        guard let window = view.window, let newView = tabViewItem?.view else {
            return
        }

        guard let frame = frame(of: window, for: newView) else {
            return
        }

        Defaults.selectedPreferenceTabIdentifier = tabViewItem?.identifier as? String
        tabView.isHidden = true

        NSAnimationContext.runAnimationGroup { context in
            window.animator().setFrame(frame, display: false)
        } completionHandler: {
            tabView.isHidden = false
            window.title = self.title ?? "Preferences"
        }
    }

    func frame(of window: NSWindow, for view: NSView) -> NSRect? {
        let contentSize = view.fittingSize
        let newFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize))
        let oldFrame = window.frame
        let newSize = newFrame.size
        let oldSize = oldFrame.size

        var frame = window.frame
        frame.size = newSize
        frame.origin.y -= (newSize.height - oldSize.height)

        return frame
    }
}
